{ config, pkgs, ... }:
{
  home.file.".local/share/fcitx5/rime" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/fcitx5/rime";
  };
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-rime
        # fcitx5-gtk
        fcitx5-nord
        kdePackages.fcitx5-configtool
        fcitx5-catppuccin
        fcitx5-tokyonight
        kdePackages.fcitx5-qt
      ];
    };
  };
}
