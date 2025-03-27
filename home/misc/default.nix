{ config, ... }:
{
  imports = [
    ./fonts
  ];

  home.file.".config/swayimg/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/misc/swayimg_config.ini";
}
