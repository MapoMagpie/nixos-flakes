{
  homeDir,
  currDir,
  mkLinkCommands,
  pkgs,
  host,
  ...
}:
let
  fuzzelIni = pkgs.writeText "fuzzel.ini" (builtins.readFile ./fuzzel/base.ini + builtins.readFile ./fuzzel/colors.ini);

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

  dconfCommands = ''
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/cursor-theme "'Bibata-Original-Amber'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Dark'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'Nordic'"
  '';

  links = [
    {
      target = ".config/mozilla/firefox/profiles.ini";
      source = "${currDir}/firefox/profiles.ini";
    }
    {
      target = ".config/mozilla/firefox/mapomagpie/user.js";
      source = "${currDir}/firefox/user.js";
    }
    {
      target = ".config/mozilla/firefox/mapomagpie/chrome";
      source = "${homeDir}/nixos/external/firefox-compact-ui";
    }
    {
      target = ".config/niri/config.kdl";
      source = "${currDir}/home/niri/config.kdl";
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
      source = "${currDir}/swayimg/init.lua";
    }
    {
      target = ".config/senime";
      source = "${homeDir}/nixos/external/senime";
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
  linkCommands = mkLinkCommands links;
in
''
  ${linkCommands}
  ${dconfCommands}
''
