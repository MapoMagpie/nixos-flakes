{ host, ... }:
{
  networking.hostName = host.hostname; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.interfaces = {
    enp34s0 = {
      wakeOnLan = {
        enable = true;
      };
    };
  };

  # Enable networking
  networking.networkmanager.enable = true;
  # 配套开关:nftables 后端 + nftables 版 NAT 模块(否则 iptables NAT 模块会
  # 强制写入 firewall.extraCommands 与 nftables 后端冲突)
  networking.nftables.enable = true;
  networking.firewall = {
    # nftables 后端才支持按源地址(网段)匹配的 extraInputRules
    backend = "nftables";
    # 放行整个局域网段的所有 TCP/UDP 端口,不再逐个列举端口
    # (192.168.1.1/24 与 192.168.1.0/24 等价,/24 覆盖 192.168.1.0~255)
    extraInputRules = ''
      ip saddr { 192.168.1.0/24, 192.168.10.0/24 } accept
    '';
  };
  # 如需从局域网之外(如公网)访问 SSH 或 qbittorrent(1999/2999/41999 等),
  # 把它们加回 allowedTCPPorts/allowedUDPPorts,只对网段外来源生效。
  # networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ];
  services.openssh = {
    enable = true;
    settings = {
      UseDns = false;
      UsePAM = false;
      X11Forwarding = true;
    };
    extraConfig = ''
      ClientAliveInterval 60
      ClientAliveCountMax 3
    '';
  };
}
