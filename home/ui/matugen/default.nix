{
  config,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.matugen ];
  home.file.".config/matugen" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/ui/matugen/config";
  };
}
