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
    sway-audio-idle-inhibit
  ];

  home.pointerCursor = with pkgs; {
    name = "Bibata-Original-Amber";
    package = bibata-cursors;
    size = 32;
  };

  # gtk = {
  #   enable = true;
  #   theme = {
  #     name = "Catppuccin-GTK-Dark";
  #     package = pkgs.magnetic-catppuccin-gtk;
  #   };
  # };

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

  # services.swayidle = {
  #   enable = true;
  #   events = [
  #     {
  #       event = "after-resume";
  #       command = "'${pkgs.niri}/bin/niri msg action power-on-monitors'";
  #     }
  #   ];
  #   timeouts = [
  #     {
  #       timeout = 300;
  #       command = "${pkgs.swaylock}/bin/swaylock -f";
  #     }
  #     {
  #       timeout = 330;
  #       command = "'${pkgs.niri}/bin/niri msg action power-off-monitors'";
  #     }
  #   ];
  # };

  programs.swaylock = {
    enable = true;
    settings = {
      # swaylock -i $FX --ring-color=00000000 --ring-clear-color=1a1a1c --indicator-radius=200 --inside-color=1f1f1f30 --indicator-thickness=15 --separator-color=00000000 --line-uses-inside --line-uses-ring --key-hl-color=f0c31f
      daemonize = true;
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
