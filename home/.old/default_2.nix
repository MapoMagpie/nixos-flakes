{
  config,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.quickshell ];
  home.file.".config/quickshell" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/ui/quickshell/config";
  };
}
