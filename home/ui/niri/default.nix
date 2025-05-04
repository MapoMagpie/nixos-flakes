{
  pkgs,
  config,
  ...
}:
{
  home.packages = [ pkgs.xwayland-satellite ];
  home.file.".config/niri/config.kdl" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/ui/niri/config.kdl";
  };
}
