{
  config,
  matugen,
  pkgs,
  ...
}:
{
  home.packages = [
    matugen.packages.${pkgs.system}.default
  ];
  home.file.".config/matugen" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/ui/matugen/config";
  };
}
