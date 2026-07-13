{ pkgs, host, ... }:
let
  nixosDir = "/home/${host.username}/nixos";

  fuzzelIni = pkgs.writeText "fuzzel.ini" (builtins.readFile ../../home/fuzzel/base.ini + builtins.readFile ../../home/fuzzel/colors.ini);

  gtk3Settings = pkgs.writeText "gtk-3.0-settings.ini" ''
    [Settings]
    gtk-theme-name=Nordic
    gtk-icon-theme-name=Papirus-Dark
    gtk-cursor-theme-name=Bibata-Original-Amber
    gtk-application-prefer-dark-theme=1
  '';

  gtk4Settings = pkgs.writeText "gtk-4.0-settings.ini" ''
    [Settings]
    gtk-theme-name=Nordic
    gtk-icon-theme-name=Papirus-Dark
    gtk-cursor-theme-name=Bibata-Original-Amber
    gtk-application-prefer-dark-theme=1
  '';

  portalConfig = pkgs.writeText "termfilechooser-config" ''
    [filechooser]
    cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
    default_dir=$HOME
    env=TERMCMD=kitty --app-id="kitty.yazi.filechooser"
  '';
in
{
  imports = [
    ./portal.nix
    ./fcitx.nix
    ./programs-ui.nix
    ./game
  ];

  # Desktop UI packages for user
  users.users."${host.username}".packages = with pkgs; [
    bibata-cursors
    adwaita-icon-theme
    papirus-icon-theme
    nordic
    cliphist
    fuzzel
    dgop
    quickshell
    dms-shell
    matugen
    firefox
    swayimg
    freerdp
    slurp
  ];

  # Desktop dotfile symlinks
  dotfiles.extraLinks = [
    {
      target = ".config/mozilla/firefox/profiles.ini";
      source = "${nixosDir}/home/firefox/profiles.ini";
    }
    {
      target = ".config/mozilla/firefox/mapomagpie/user.js";
      source = "${nixosDir}/home/firefox/user.js";
    }
    {
      target = ".config/mozilla/firefox/mapomagpie/chrome";
      source = "${nixosDir}/external/firefox-compact-ui";
    }
    {
      target = ".config/niri/config.kdl";
      source = "${nixosDir}/home/niri/${host.niriConfig or "config.kdl"}";
    }
    {
      target = ".config/fuzzel/fuzzel.ini";
      source = fuzzelIni;
    }
    {
      target = ".config/xdg-desktop-portal-termfilechooser/config";
      source = portalConfig;
    }
    {
      target = ".config/swayimg/init.lua";
      source = "${nixosDir}/home/swayimg/init.lua";
    }
    {
      target = ".config/senime";
      source = "${nixosDir}/external/senime";
    }
    {
      target = ".config/gtk-3.0/settings.ini";
      source = gtk3Settings;
    }
    {
      target = ".config/gtk-4.0/settings.ini";
      source = gtk4Settings;
    }
    {
      target = ".local/share/applications/swayimg.desktop";
      source = "${pkgs.swayimg}/share/applications/swayimg.desktop";
    }
  ];
}
