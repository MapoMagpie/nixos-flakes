{ host, ... }:
{
  imports = [
    ./qbittorrent.nix
    ./logind.nix
  ]
  # 旁路网关（mihomo TProxy）：只给需要做网关的机器开启
  ++ (if host.enable_gateway or false then [ ./gateway.nix ] else [ ]);
}
