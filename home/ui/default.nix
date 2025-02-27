{ pkgs, ... }:
{
  imports = [
    ./ironbar
    ./niri
    ./fuzzel
  ];

  home.packages = with pkgs; [
    swww
  ];

  home.pointerCursor = with pkgs; {
    name = "Bibata-Original-Amber";
    package = bibata-cursors;
    size = 32;
  };
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-theme = "Bibata-Original-Amber";
      color-scheme = "prefer-dark";
    };
  };
  services.mako = {
    enable = true;
    backgroundColor = "#1f1f1fc3";
    width = 300;
    height = 110;
    borderColor = "#f0c30f";
    borderRadius = 0;
    borderSize = 2;
    # icons = false;
    maxIconSize = 64;
    defaultTimeout = 5000;
    # extraConfig = ''
    #   [urgency=low]
    #   border-color=#cccccc
    #   [urgency=normal]
    #   border-color=#f0c30f
    #   [urgency=high]
    #   border-color=#bf616a
    #   default-timeout=50000
    #   [category=mpd]
    #   border-color=#cccccc
    #   default-timeout=2000
    # '';
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        # before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 330;
          on-timeout = "niri msg action power-off-monitors";
          on-resume = "niri msg action power-on-monitors";
        }
        {
          timeout = 300;
          on-timeout = "hyprlock";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    extraConfig = (builtins.readFile ./hyprlock.conf);
  };

}
