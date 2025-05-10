{
  pkgs,
  swww,
  ...
}:
{
  imports = [
    ./niri
    ./fuzzel
  ];

  home.packages = with pkgs; [
    mpvpaper
    swww.packages.${pkgs.system}.swww
  ];

  home.pointerCursor = with pkgs; {
    name = "Bibata-Original-Amber";
    package = bibata-cursors;
    size = 32;
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk4.extraCss = ''
      @import 'colors.css'
    '';
    gtk3.extraCss = ''
      @import 'colors.css'
    '';
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-theme = "Bibata-Original-Amber";
      color-scheme = "prefer-dark";
    };
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
    extraConfig = (builtins.readFile ./hyprland/hyprlock.conf);
  };

}
