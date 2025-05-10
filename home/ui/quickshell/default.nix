{
  config,
  quickshell,
  pkgs,
  ...
}:
{
  home.packages = [
    quickshell.packages.${pkgs.system}.default
  ];
  home.file.".config/quickshell" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/ui/quickshell/quickshell";
  };
}
