{ pkgs, host, ... }:
{

  file.xdg_config = {
    "mozilla/firefox/profiles.ini".source = ../../home/firefox/profiles.ini;
    "mozilla/firefox/mapomagpie/user.js".source = ../../home/firefox/user.js;
    "mozilla/firefox/mapomagpie/chrome".source = "{{home}}/nixos/external/firefox-compact-ui";

    "niri/config.kdl".source = if host.hostname == "maponixos" then "{{home}}/nixos/home/niri/config.kdl" else "{{home}}/nixos/home/niri/config_slave.kdl";
    "fuzzel/fuzzel.ini".text =
      let
        base = builtins.readFile ../../home/fuzzel/base.ini;
        colors = builtins.readFile ../../home/fuzzel/colors.ini;
      in
      base + colors;
    "quickshell".source = "{{home}}/nixos/home/quickshell";
    "matugen".source = "{{home}}/nixos/home/matugen";
    "xdg-desktop-portal-termfilechooser/config".text = ''
      [filechooser]
      cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
      default_dir=$HOME
      env=TERMCMD=kitty --app-id="kitty.yazi.filechooser"
    '';
    "xdg-desktop-portal/portals.conf".text = ''
      [preferred]
      org.freedesktop.impl.portal.FileChooser=termfilechooser
    '';
    "swayimg/config".source = "{{home}}/nixos/home/swayimg/swayimg_config.ini";
    "swaylock/config".source = "{{home}}/nixos/home/swaylock/config";
  };
  file.xdg_data = {
    "fcitx5/rime".source = "{{home}}/nixos/external/rime";
  };
  packages =
    with pkgs;
    [
      mpvpaper
      sway-audio-idle-inhibit

      bibata-cursors

      cliphist
      fuzzel
      quickshell
      matugen
      firefox
      swaylock
      swayidle
      dragon-drop
      swayimg
      wf-recorder
      freerdp
      slurp
    ]
    ++ (
      if host.hostname == "maponixos" then
        [
          # tsukimi
          # zed-editor
          gimp3
          # kdePackages.kdenlive
          telegram-desktop
          chromium
          codex
          claude-code
        ]
      else if host.hostname == "slavenixos" then
        [
          telegram-desktop
        ]
      else
        [ ]
    );
  dconf.settings = {
    "/org/gnome/desktop/interface/color-scheme" = "prefer-dark";
    "/org/gnome/desktop/interface/cursor-theme" = "Bibata-Original-Amber";
  };
}
