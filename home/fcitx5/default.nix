{ config, ... }:
{
  home.file.".local/share/fcitx5/rime" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/fcitx5/rime";
  };
}
