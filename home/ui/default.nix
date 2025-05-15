{
  pkgs,
  swww,
  ...
}:
{
  imports = [
    ./niri
    ./fuzzel
    ./quickshell
    ./matugen
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
        lock_cmd = "pidof swaylock || swaylock";
      };
      listener = [
        {
          timeout = 330;
          on-timeout = "niri msg action power-off-monitors";
          on-resume = "niri msg action power-on-monitors";
        }
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
      ];
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      # swaylock -i $FX --ring-color=00000000 --ring-clear-color=1a1a1c --indicator-radius=200 --inside-color=1f1f1f30 --indicator-thickness=15 --separator-color=00000000 --line-uses-inside --line-uses-ring --key-hl-color=f0c31f
      image = "~/nixos/home/images/wallpapers/lock.jpg";
      ring-color = "00000000";
      ring-clear-color = "1a1a1c";
      indicator-radius = "200";
      indicator-thickness = "15";
      inside-color = "1f1f1f30";
      separator-color = "00000000";
      key-hl-color = "f0c31f";
      line-uses-inside = true;
      line-uses-ring = true;
    };
  };

}
