# 旁路网关（bypass gateway）：mihomo TProxy + 策略路由 + DNS 接管
#
# 文档：nixos-gateway/README.md   参考实现：nixos-gateway/mihomo-gateway.nix
# 前提：单网卡（LAN / WAN 同口），局域网客户端的「默认网关」与「DNS」都指向本机。
#
# 相对参考实现的三处调整：
#   1. 同时代理 IPv4 与 IPv6（inet 表天然覆盖两族；v6 用独立的策略路由表 101）。
#   2. mihomo 的配置文件放在用户家目录（~/.config/mihomo/config.yaml），
#      通过 systemd LoadCredential 在启动时读取 —— 不进 nix store，
#      改配置只要 `systemctl restart mihomo`，不需要 nixos-rebuild。
#   3. 不用 services.mihomo：它的 sandbox（PrivateUsers / RestrictAddressFamilies）
#      会让 IP_TRANSPARENT 拿不到 host netns 的 CAP_NET_ADMIN，TProxy 会失败。
#
# 注意：下面的 nft 规则必须与 ~/.config/mihomo/config.yaml 对齐（参考
# nixos-gateway/mihomo/config.yaml），至少这几项：
#   tproxy-port: 7893        routing-mark: 356 (= 0x164)
#   ipv6: true               fake-ip-range: 198.18.0.0/15
#   fake-ip-range6: fc00::/16  dns.listen: 0.0.0.0:1053
# 改动其中任何一项时，请同步修改本文件顶部的 let 常量。

{
  config,
  pkgs,
  lib,
  host,
  ...
}:

let
  # ================= 需要按实际情况修改 =================
  lanIfaces = [ "enp2s0" ]; # 面向局域网/客户端的网卡（ip link 查看）；[] = 不限制接口

  # 局域网网段（v4）。[] = 不按源地址限制，只靠上面的网卡限制
  lanSubnets = [
    "192.168.1.0/24"
    "192.168.10.0/24"
  ];

  # 局域网 IPv6 前缀（例如 "2001:db8:1::/64"）。
  # null = 不按 v6 源地址限制（单网卡下只靠 lanIfaces 限制即可）
  lanSubnet6 = null;

  tproxyPort = 7893; # TProxy 监听端口（TCP + UDP，v4/v6 共用）
  dnsPort = 1053; # mihomo DNS 监听端口（避开 systemd-resolved 的 53）
  # apiPort = 9090; # 面板 / RESTful API（仅 LAN 可访问）
  # httpPort = 7890; # 可选：给不方便改网关的设备手动填 HTTP/SOCKS 代理

  tproxyMark = "0x162"; # TProxy 标记（配合 ip rule），= 354
  routingMark = "0x164"; # mihomo 自身出站标记（防回环），= 356
  routeTable = 100; # 策略路由表号（v4）
  routeTable6 = 101; # 策略路由表号（v6，必须与 v4 分开）

  # fake-ip 网段：必须与 config.yaml 的 fake-ip-range / fake-ip-range6 一致
  fakeIpRange = "198.18.0.0/15";
  fakeIpRange6 = "fc00::/16";

  # 端口白名单：目的地址不在 fake-ip 段内时，只有这些端口才进 mihomo
  # 想让「IP 直连」的应用（游戏/语音/P2P）也走代理，就扩大这个列表
  extraPorts = [
    80
    443
    8080
    8443
  ];

  # 完全不走代理的设备 MAC（nft 里写作 aa:bb:cc:dd:ee:ff，不加引号）
  bypassMacs = [ ];

  # 是否把局域网发往任意地址的 v6:53 也重定向到 mihomo。
  # 开启后 config.yaml 的 dns.listen 必须双栈（":1053" / "[::]:1053"），
  # 否则 v6 客户端 DNS 会被 RST。默认关闭：v6 DNS 走客户端原来的解析器，
  # 仅失去 fake-ip6（v6 的域名分流退化，IP 规则与端口白名单仍然生效）。
  hijackDns6 = true;

  # mihomo 配置文件：用户家目录，不在 nix store 里
  userHome = config.users.users.${host.username}.home;
  configFile = "${userHome}/.config/mihomo/config.yaml";

  # ================= 规则片段生成 =================
  ifaceRule = lib.optionalString (lanIfaces != [ ]) (lib.concatMapStringsSep "\n  " (i: "iifname != \"${i}\" return") lanIfaces);

  lanRule4 = lib.optionalString (lanSubnets != [ ]) "meta nfproto ipv4 ip saddr != { ${lib.concatStringsSep ", " lanSubnets} } return";

  lanRule6 = lib.optionalString (lanSubnet6 != null) "meta nfproto ipv6 ip6 saddr != { ${lanSubnet6} } return";

  bypassMacRule = lib.optionalString (bypassMacs != [ ]) "ether saddr { ${lib.concatStringsSep ", " bypassMacs} } return";

  portList = "{ " + lib.concatStringsSep ", " (map toString extraPorts) + " }";
  portRule = lib.optionalString (extraPorts != [ ]) (
    lib.concatStringsSep "\n  " [
      "# 语义：目的地址在 fake-ip 段内 -> 无条件进 mihomo；"
      "#       否则必须端口在白名单内，其余交给内核转发（直连）"
      "ip daddr != { ${fakeIpRange} } tcp dport != ${portList} return"
      "ip daddr != { ${fakeIpRange} } udp dport != ${portList} return"
      "ip6 daddr != { ${fakeIpRange6} } tcp dport != ${portList} return"
      "ip6 daddr != { ${fakeIpRange6} } udp dport != ${portList} return"
    ]
  );

  dns6Rule = lib.optionalString (!hijackDns6) (
    lib.concatStringsSep "\n  " [
      "# hijackDns6 = false：v6 的 53 不劫持（dns.listen 改双栈后可放开）"
      "meta nfproto ipv6 return"
    ]
  );

  # 开了 v6 转发后内核不再处理 RA，必须 accept_ra = 2 才拿得到 v6 地址/默认路由
  acceptRa = lib.listToAttrs (map (i: lib.nameValuePair "net.ipv6.conf.${i}.accept_ra" 2) lanIfaces);

  mihomoRuleset = ''
    # ---------------------------------------------------------------
    # 链 1：决定「谁进 mihomo」
    # priority mangle(-150) 早于 dstnat(-100)，所以本链先跑
    # 规则顺序即优先级，命中 return 就回到内核转发路径（直连）
    # 注意：'tproxy' 是 nft 保留字，链名用 tp_in
    # ---------------------------------------------------------------
    chain tp_in {
      type filter hook prerouting priority mangle; policy accept;

      # (1) DNS 交给下面的 dns 链处理，不当代理流量
      udp dport 53 return
      tcp dport 53 return

      # (2) 防回环：mihomo 自己出站打了 ${routingMark}，不再劫持
      meta mark ${routingMark} return

      # (3) 本机 / 保留地址直连（NAS、打印机、SSH、mDNS、组播）
      ip daddr { 0.0.0.0/8, 10.0.0.0/8, 127.0.0.0/8, 100.64.0.0/10,
                 169.254.0.0/16, 172.16.0.0/12, 192.168.0.0/16,
                 224.0.0.0/4, 240.0.0.0/4 } return

      # (3b) v6 保留地址直连；ULA 里排除 fake-ip6 网段（否则 v6 永远进不来）
      ip6 daddr { ::1/128, fe80::/10, ff00::/8 } return
      ip6 daddr fc00::/7 ip6 daddr != { ${fakeIpRange6} } return

      # (4) 只处理来自局域网的流量
      ${lanRule4}
      ${lanRule6}

      # (4b) 只处理从局域网网卡进来的流量（lanIfaces = [] 时本段不生成）
      ${ifaceRule}

      # (5) MAC 黑名单：这些设备完全绕过代理
      ${bypassMacRule}

      # (6) 端口白名单
      ${portRule}

      # (7) 劫持：不改包，打 mark 后交给本机 transparent socket（v4 + v6）
      meta l4proto { tcp, udp } meta mark set ${tproxyMark} tproxy to :${toString tproxyPort} accept
    }

    # ---------------------------------------------------------------
    # 链 2：把客户端发往任意地址的 53 重定向到 mihomo DNS
    # REDIRECT 是 conntrack 动作，回程会被正确反 NAT
    # ---------------------------------------------------------------
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
  # ================= 1. 内核 =================
  boot.kernelModules = [
    "nft_tproxy"
    "nf_conntrack"
  ];

  boot.kernel.sysctl = {
    # 旁路网关必须转发；否则被 return 掉（不代理）的流量会被直接丢弃
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;

    # TProxy 的 socket 绑定非本机地址，strict rp_filter 可能丢包
    "net.ipv4.conf.all.rp_filter" = 2;
    "net.ipv4.conf.default.rp_filter" = 2;
  }
  // acceptRa;

  # ================= 2. 防火墙 =================
  networking.nftables.enable = lib.mkDefault true;

  networking.firewall = {
    enable = true; # 保留它做 input 保护（挡住来自 WAN 的 7890 / 9090）
    checkReversePath = false; # 关掉 nixos-fw 的 rpfilter，避免误丢 tproxy 包
    filterForward = false; # 旁路网关必须放行全部转发
  };

  environment.systemPackages = with pkgs; [
    mihomo
    nftables
    iproute2
    conntrack-tools
    bind.dnsutils
  ];

  # ================= 3. nftables：TProxy + DNS 劫持 =================
  networking.nftables.tables.mihomo = {
    family = "inet";
    content = mihomoRuleset;
  };

  # ================= 4. 策略路由（TProxy 的唯一必需前提） =================
  # TProxy 不改包，目标地址不是本机 -> 正常 FIB 会转发出去。
  # 打上 fwmark 后，table 里的 local 路由让内核把它当作 input 交给 socket。
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

  # ================= 5. mihomo 服务 =================
  # IP_TRANSPARENT 需要 CAP_NET_ADMIN（CAP_NET_RAW 作保险）
  # 注意：不要设 NoNewPrivileges = true（会禁用 AmbientCapabilities）；
  #       也不要 PrivateUsers = true / ProtectHome = true（前者拿不到 host netns 的
  #       capability，后者挡住家目录里的配置文件）
  users.groups.mihomo = { };
  users.users.mihomo = {
    isSystemUser = true;
    group = "mihomo";
    home = "/var/lib/mihomo";
  };

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

      # 配置文件放在家目录、不进 nix store；由 PID1 读取后以 credential 形式交给服务，
      # 因此 ~/.config/mihomo/config.yaml 即使 0600 也能工作。
      # 改完配置执行：systemctl restart mihomo
      LoadCredential = "config.yaml:${configFile}";
      ExecStart = "${pkgs.mihomo}/bin/mihomo -d /var/lib/mihomo -f %d/config.yaml";
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

      # 只读加固（注意上面两条：不要 NoNewPrivileges / PrivateUsers / ProtectHome）
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

  # ================= 6. 本机解析保持原样 =================
  # 本机（本机进程）流量走 output，不会被劫持，systemd-resolved 继续用 127.0.0.53。
  # 想让本机流量也走代理，见 nixos-gateway/README.md 附录 B（或给程序设
  # http_proxy=http://127.0.0.1:${toString httpPort}）。
  # 面板：http://<本机 LAN IP>:${toString apiPort}/ui （config.yaml 的 external-controller）
}
