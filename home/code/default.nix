{
  pkgs,
  host,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    nil
    nixfmt-rfc-style
  ];
  home.file.".config/helix/themes".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/code/helix/themes";
  home.file.".config/helix/config.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/code/helix/config.toml";
  home.file.".config/helix/languages.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/code/helix/languages.toml";

  programs.zed-editor = {
    enable = host.hostname == "maponixos";
  };
}
