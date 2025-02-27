{
  ironbar,
  config,
  host,
  ...
}:
{
  imports = [ ironbar.homeManagerModules.default ];
  home.file.".config/ironbar/config.toml" =
    if host.hostname == "maponixos" then
      {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/ui/ironbar/config.toml";
      }
    else
      {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/ui/ironbar/config.toml";
      };

  home.file.".config/ironbar/style.css".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/ui/ironbar/style.css";
  programs.ironbar = {
    enable = true;
    config = "";
  };
}
