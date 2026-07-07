{ pkgs, host, ... }:
{
  services.mihomo = {
    enable = true;
    webui = pkgs.metacubexd;
    tunMode = true;
    configFile = "/home/${host.username}/.config/clash/config.yaml";
  };
}
