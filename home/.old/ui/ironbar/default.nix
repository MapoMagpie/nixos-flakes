{
  ironbar,
  config,
  host,
  ...
}:
{
  imports = [ ironbar.homeManagerModules.default ];
  home.file.".config/ironbar/config.yaml" =
    if host.hostname == "maponixos" then
      {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/ui/ironbar/config.yaml";
      }
    else
      {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/ui/ironbar/config.yaml";
      };

  home.file.".config/ironbar/style.css".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/ui/ironbar/style.css";
  programs.ironbar = {
    enable = true;
    config = "";
  };
}
