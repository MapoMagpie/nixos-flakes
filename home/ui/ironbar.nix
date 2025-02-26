{ ironbar, config, ... }:
{
  imports = [ ironbar.homeManagerModules.default ];
  home.file.".config/ironbar/config.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/ui/ironbar/config.toml";
  home.file.".config/ironbar/style.css".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/ui/ironbar/style.css";
  home.file.".config/ironbar/ironbar-ddc-module.sh".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/ui/ironbar/ironbar-ddc-module.sh";
  programs.ironbar = {
    enable = true;
    config = "";
  };
}
# config = { };
# style = "";
# package = ironbar;
# features = [
#   "http"
#   "ipc"
#   "cli"
#   "config+toml"
#   "cairo"
#   "clipboard"
#   "click"
#   "focused"
#   "keyboard"
#   "launcher"
#   "music+all"
#   "network_manager"
#   "notifications"
#   "sys_info"
#   "tray"
#   "upower"
#   "volume"
#   "schema"
#   "workspace+niri"
# ];
