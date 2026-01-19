{
  pkgs,
  config,
  host,
  ...
}:
{
  home.packages = [ pkgs.xwayland-satellite ];
  home.file.".config/niri/config.kdl" = {
    source = config.lib.file.mkOutOfStoreSymlink (if host.hostname == "maponixos" then "${config.home.homeDirectory}/nixos/home/ui/niri/config.kdl" else "${config.home.homeDirectory}/nixos/home/ui/niri/config_slave.kdl");
  };
}
