{ config, ... }:
{
  # home.file.".local/share/fonts".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/misc/fonts";
  # fonts.fontconfig.enable = true;
  home.file.".config/swayimg/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/misc/swayimg_config.ini";
}
