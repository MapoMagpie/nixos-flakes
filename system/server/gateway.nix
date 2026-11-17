# 旁路网关：mihomo TProxy + 策略路由 + DNS 接管（文档：nixos-gateway/README.md）
# 前提：单网卡（LAN/WAN 同口），局域网客户端的「网关」和「DNS」都指向本机。
#
# 相对参考实现（nixos-gateway/mihomo-gateway.nix）的差异：
#   1. 同时代理 IPv4 / IPv6（inet 表天然覆盖两族，v6 用独立策略路由表 101）。
#   2. mihomo 配置放在 ~/.config/mihomo/config.yaml，不进 nix store：
#      改配置只要 `systemctl restart mihomo`，不用 rebuild。
#   3. 不用 services.mihomo：它的 PrivateUsers / RestrictAddressFamilies 会让
#      IP_TRANSPARENT 拿不到 host netns 的 CAP_NET_ADMIN，TProxy 起不来。
#
# 下面 let 里的常量必须与 config.yaml 对齐（tproxy-port / routing-mark /
# fake-ip-range / fake-ip-range6 / ipv6 / dns.listen），否则规则和 mihomo 对不上。

{
  config,
  pkgs,
  lib,
  host,
  ...
}:

let
  # ===== 按实际情况修改 =====
  lanIfaces = [ "enp2s0" ]; # 局域网网卡；[] = 不限制接口
  lanSubnets = [
    "192.168.1.0/24"
    "192.168.10.0/24"
  ]; # 局域网 v4 网段；[] = 不限制源地址
  lanSubnet6 = null; # 局域网 v6 前缀；null = 不限制（单网卡下靠 lanIfaces 即可）

  tproxyPort = 7893; # TProxy（TCP+UDP，v4/v6 共用）
  dnsPort = 1053; # mihomo DNS（避开 systemd-resolved 的 53）
  # apiPort = 9090; # 面板 / RESTful API
  # httpPort = 7890; # mixed-port，给不便改网关的设备手动填代理

  tproxyMark = "0x162"; # TProxy 标记（配合 ip rule），= 354
  routingMark = "0x164"; # mihomo 自身出站标记（防回环），= 356
  routeTable = 100; # v4 策略路由表
  routeTable6 = 101; # v6 策略路由表（必须与 v4 分开）

  fakeIpRange = "198.18.0.0/15"; # = config.yaml 的 fake-ip-range
  fakeIpRange6 = "fc00::/16"; # = config.yaml 的 fake-ip-range6

  # 端口白名单：目的地址不在 fake-ip 段内时，只有这些端口才进 mihomo。
  # 想让 IP 直连的应用（游戏/语音/P2P）也走代理，就扩大或清空这个列表。
  extraPorts = [
    80
    443
    8080
    8443
  ];

  bypassMacs = [ ]; # 完全不走代理的设备 MAC（如 "aa:bb:cc:dd:ee:ff"，不加引号）

  # 是否也劫持 v6:53。开启前必须把 config.yaml 的 dns.listen 改成双栈（":1053"），
  # 否则 v6 客户端 DNS 会被 RST。
  hijackDns6 = false;

  # ===== 配置路径 =====
  userHome = config.users.users.${host.username}.home;
  configFile = "${userHome}/.config/mihomo/config.yaml";

  # ===== 规则片段 =====
  ifaceRule = lib.optionalString (lanIfaces != [ ]) (
    lib.concatMapStringsSep "\n  " (i: "iifname != \"${i}\" return") lanIfaces
  );

  lanRule4 = lib.optionalString (
    lanSubnets != [ ]
  ) "meta nfproto ipv4 ip saddr != { ${lib.concatStringsSep ", " lanSubnets} } return";

  lanRule6 = lib.optionalString (
    lanSubnet6 != null
  ) "meta nfproto ipv6 ip6 saddr != { ${lanSubnet6} } return";

  bypassMacRule = lib.optionalString (bypassMacs != [ ]) (
    "ether saddr { ${lib.concatStringsSep ", " bypassMacs} } return"
  );

  portList = "{ " + lib.concatStringsSep ", " (map toString extraPorts) + " }";
  portRule = lib.optionalString (extraPorts != [ ]) (
    lib.concatStringsSep "\n  " [
      "# fake-ip 目的地址无条件进 mihomo；否则必须端口在白名单内"
      "ip daddr != { ${fakeIpRange} } tcp dport != ${portList} return"
      "ip daddr != { ${fakeIpRange} } udp dport != ${portList} return"
      "ip6 daddr != { ${fakeIpRange6} } tcp dport != ${portList} return"
      "ip6 daddr != { ${fakeIpRange6} } udp dport != ${portList} return"
    ]
  );

  dns6Rule = lib.optionalString (!hijackDns6) "meta nfproto ipv6 return";

  # 开了 v6 转发后内核不再处理 RA，accept_ra=2 才能拿到 v6 地址 / 默认路由
  acceptRa = lib.listToAttrs (map (i: lib.nameValuePair "net.ipv6.conf.${i}.accept_ra" 2) lanIfaces);

  mihomoRuleset = ''
    # 链 1：决定「谁进 mihomo」。priority mangle(-150) 早于 dstnat(-100)，先跑。
    # 规则顺序即优先级，命中 return 就回到内核转发路径（直连）。
    # 注意：'tproxy' 是 nft 保留字，所以链名用 tp_in。
    chain tp_in {
      type filter hook prerouting priority mangle; policy accept;

      udp dport 53 return # DNS 交给下面的 dns 链
      tcp dport 53 return

      meta mark ${routingMark} return # mihomo 自己的出站，防回环

      ip daddr { 0.0.0.0/8, 10.0.0.0/8, 127.0.0.0/8, 100.64.0.0/10,
                 169.254.0.0/16, 172.16.0.0/12, 192.168.0.0/16,
                 224.0.0.0/4, 240.0.0.0/4 } return # 保留地址直连

      # v6 保留地址直连，但 ULA 里的 fake-ip6 网段要留下
      ip6 daddr { ::1/128, fe80::/10, ff00::/8 } return
      ip6 daddr fc00::/7 ip6 daddr != { ${fakeIpRange6} } return

      ${lanRule4}
      ${lanRule6}
      ${ifaceRule}
      ${bypassMacRule}
      ${portRule}

      meta l4proto { tcp, udp } meta mark set ${tproxyMark} tproxy to :${toString tproxyPort} accept
    }

    # 链 2：把客户端发往任意地址的 53 重定向到 mihomo DNS
    chain dns {
      type nat hook prerouting priority dstnat; policy accept;

      udp dport != 53 return
      tcp dport != 53 return
      meta mark ${routingMark} return
      ${lanRule4}
      ${ifaceRule}
      ${dns6Rule}

      # redirect 必须紧跟在 L4 协议匹配之后（nft 静态检查要求）
      udp dport 53 redirect to :${toString dnsPort}
      tcp dport 53 redirect to :${toString dnsPort}
    }
  '';
in
{
  boot.kernelModules = [
    "nft_tproxy"
    "nf_conntrack"
  ];

  boot.kernel.sysctl = {
    # 旁路网关必须转发，否则被 return 掉的流量会被直接丢弃
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;

    # TProxy socket 绑定非本机地址，strict rp_filter 会丢包
    "net.ipv4.conf.all.rp_filter" = 2;
    "net.ipv4.conf.default.rp_filter" = 2;
  }
  // acceptRa;

  networking.nftables.enable = lib.mkDefault true;

  networking.firewall = {
    enable = true; # 保留 input 保护（挡住来自 WAN 的 7890/9090）
    checkReversePath = false; # 避免 nixos-fw 的 rpfilter 误丢 tproxy 包
    filterForward = false; # 旁路网关必须放行全部转发
  };

  environment.systemPackages = with pkgs; [
    mihomo # 方便本机用 `mihomo -t` 校验配置
    nftables
    iproute2
    conntrack-tools
    bind.dnsutils
  ];

  networking.nftables.tables.mihomo = {
    family = "inet";
    content = mihomoRuleset;
  };

  # TProxy 不改包，目标地址不是本机时正常 FIB 只会转发出去；
  # 打上 fwmark 后用 local 路由让内核把它当作 input 交给 socket。
  systemd.services.mihomo-tproxy-route = {
    description = "Policy routing for mihomo TPROXY (fwmark ${tproxyMark} -> table ${toString routeTable}/${toString routeTable6})";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "nftables.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -e
      ${pkgs.iproute2}/bin/ip -4 rule del fwmark ${tproxyMark} table ${toString routeTable} 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip -4 rule add fwmark ${tproxyMark} table ${toString routeTable}
      ${pkgs.iproute2}/bin/ip -4 route replace local default dev lo table ${toString routeTable}

      ${pkgs.iproute2}/bin/ip -6 rule del fwmark ${tproxyMark} table ${toString routeTable6} 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip -6 rule add fwmark ${tproxyMark} table ${toString routeTable6}
      ${pkgs.iproute2}/bin/ip -6 route replace local default dev lo table ${toString routeTable6}
    '';

    preStop = ''
      ${pkgs.iproute2}/bin/ip -4 rule del fwmark ${tproxyMark} table ${toString routeTable} 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip -4 route flush table ${toString routeTable} 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip -6 rule del fwmark ${tproxyMark} table ${toString routeTable6} 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip -6 route flush table ${toString routeTable6} 2>/dev/null || true
    '';
  };

  users.groups.mihomo = { };
  users.users.mihomo = {
    isSystemUser = true;
    group = "mihomo";
    home = "/var/lib/mihomo";
  };

  # 注意三条约束：
  #   - IP_TRANSPARENT 需要 CAP_NET_ADMIN，所以不能设 NoNewPrivileges = true；
  #   - 不能设 PrivateUsers = true，否则拿不到 host netns 的 capability；
  #   - 配置文件在家目录，ProtectHome 只能 read-only（且靠 LoadCredential 读取）。
  systemd.services.mihomo = {
    description = "mihomo (Clash.Meta) transparent proxy for bypass gateway";
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "nftables.service"
      "mihomo-tproxy-route.service"
    ];
    requires = [ "mihomo-tproxy-route.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "mihomo";
      Group = "mihomo";

      # 配置由 PID1 读取后以 credential 交给服务，所以 0600 也能用；
      # 改完配置执行：systemctl restart mihomo
      LoadCredential = "config.yaml:${configFile}";
      ExecStart = "${pkgs.mihomo}/bin/mihomo -d /var/lib/mihomo -f %d/config.yaml -ext-ui ${pkgs.metacubexd}";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/mihomo/ruleset /var/lib/mihomo/providers";

      Restart = "always";
      RestartSec = 3;
      LimitNOFILE = 65535;

      AmbientCapabilities = [
        "CAP_NET_ADMIN"
        "CAP_NET_RAW"
      ];
      CapabilityBoundingSet = [
        "CAP_NET_ADMIN"
        "CAP_NET_RAW"
      ];
      StateDirectory = "mihomo";
      StateDirectoryMode = "0750";

      ProtectSystem = "strict";
      ProtectHome = "read-only";
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectHostname = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];
      SystemCallArchitectures = "native";
      UMask = "0077";
    };
  };

  # 面板：http://<本机 LAN IP>:${toString apiPort}/ui（external-controller 见 config.yaml）
  # 本机进程走 output，不会被劫持；想代理本机流量见 README 附录 B，或设
  # http_proxy=http://127.0.0.1:${toString httpPort}。

  # ================= 7. 本机自身的 DNS：DoT 防污染 =================
  # 旁路网关自己的解析走 systemd-resolved + DoT（TCP 853），既不经过 mihomo、
  # 也不受运营商对明文 53 的投毒影响 —— github.com / githubusercontent.com
  # 这类常被解析到错误 IP 的域名，在本机上直接拿到真实地址，git / curl 无需代理。
  # （局域网客户端的 DNS 仍由 mihomo:1053 接管，见上面的 chain dns）
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [
        "223.5.5.5#dns.alidns.com"
        "1.12.12.12#dot.pub"
        "1.1.1.1#cloudflare-dns.com"
      ];
      # 严格模式：绝不退回到明文 53（否则等于没防污染）。
      # 三个服务器都不可达时本机完全无法解析 —— 这比静默被投毒更好排查。
      DNSOverTLS = "yes";
      # 全局默认路由：所有域名都走上面三个 DoT，不用链路下发的域名
      Domains = [ "~." ];
      # 想开 DNSSEC 就取消注释；个别国内域名 DNSSEC 配错会导致解析失败
      # DNSSEC = "allow-downgrade";
    };
  };

  # 坑：services.resolved 默认把 NM 的 DNS 模式设成 systemd-resolved，
  # 但 NM 仍会把 DHCP 下发的（可能被污染的）DNS 作为「链路级默认路由」交给
  # resolved，而链路级设置优先于上面的全局 DoT —— 结果就是投毒照样生效。
  # 强制 "none" 后 NM 不再触碰 DNS，本机解析只认 resolved.conf 里的 DoT。
  networking.networkmanager.dns = lib.mkForce "none";
}
