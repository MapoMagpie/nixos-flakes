{
  pkgs,
  host,
  lib,
  ...
}:
let
  home = "/home/${host.username}";
  nixosDir = "${home}/nixos";

  # ── Text-based files (built into nix store) ─────────────────
  bashrc = pkgs.writeText "bashrc" ''
    enable -f ${pkgs.flyline}/lib/libflyline.so flyline
    flyline suggestions --auto-suggest true
    flyline create-prompt-widget custom --name STARSHIP --command "${nixosDir}/home/misc/scripts/shell_prompt.sh" --placeholder prev
    PS1='\e[01;32m\w\e[00m \e[02m[\t]\e[00m STARSHIP \n\e[01;32m:\e[00m'
    PS1_FINAL='\e[02m[\t]\W>|\e[00m'
    eval "$(${pkgs.zoxide}/bin/zoxide init bash)"
    source ${nixosDir}/home/misc/scripts/yazi_cwd.sh
    alias bos='sudo nixos-rebuild switch --flake ~/nixos && notify-send "nixos build succeeded"'
    alias h='hx .'
    alias kt='kitty @ launch --type=os-window --cwd=current --copy-env'
    alias nu='nix flake update'
    alias y=yazi_cwd
    nd() {
      if [ -z "$1" ]; then
        nix develop
      else
        nix develop ~/nixos#"$1"
      fi
    }
    SAVEHIST=100000
    HISTSIZE=100000
    HISTCONTROL=ignoredups:erasedups
    shopt -s histappend
    export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
  '';

  gitConfig = pkgs.writeText "gitconfig" ''
    [user]
    	name = "${host.git.userName}"
    	email = "${host.git.userEmail}"
  '';

  fuzzelIni = pkgs.writeText "fuzzel.ini" (builtins.readFile ../home/fuzzel/base.ini + builtins.readFile ../home/fuzzel/colors.ini);

  gtk3Settings = pkgs.writeText "gtk-3.0-settings.ini" ''
    [Settings]
    gtk-theme-name=Catppuccin-Mocha-Standard-Blue-Dark
    gtk-icon-theme-name=Papirus-Dark
    gtk-cursor-theme-name=Bibata-Original-Amber
    gtk-application-prefer-dark-theme=1
  '';

  gtk4Settings = pkgs.writeText "gtk-4.0-settings.ini" ''
    [Settings]
    gtk-theme-name=Catppuccin-Mocha-Standard-Blue-Dark
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

  # ── Symlink rules ───────────────────────────────────────────
  # Each entry: { target = "..."; source = "..."; }

  # nixfmt:disable
  commonLinks = [
    # ── maid/default.nix ──
    {
      target = ".bashrc";
      source = bashrc;
    }
    {
      target = ".config/git/config";
      source = gitConfig;
    }
    {
      target = ".config/yazi";
      source = "${nixosDir}/home/yazi";
    }
    {
      target = ".config/kitty";
      source = "${nixosDir}/home/kitty";
    }
    {
      target = ".config/television";
      source = "${nixosDir}/home/television";
    }
    {
      target = ".config/helix";
      source = "${nixosDir}/home/helix";
    }
  ];
  # nixfmt:enable

  uiLinks = [
    # ── maid/ui.nix ──
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
      source = if host.hostname == "maponixos" then "${nixosDir}/home/niri/config.kdl" else "${nixosDir}/home/niri/config_slave.kdl";
    }
    {
      target = ".config/fuzzel/fuzzel.ini";
      source = fuzzelIni;
    }
    # {
    #   target = ".config/quickshell";
    #   source = "${nixosDir}/home/quickshell";
    # }
    {
      target = ".config/xdg-desktop-portal-termfilechooser/config";
      source = portalConfig;
    }
    {
      target = ".config/swayimg/init.lua";
      source = "${nixosDir}/home/swayimg/init.lua";
    }
    {
      target = ".config/gtk-3.0/settings.ini";
      source = gtk3Settings;
    }
    {
      target = ".config/gtk-4.0/settings.ini";
      source = gtk4Settings;
    }
    # ── XDG_DATA_HOME ──
    {
      target = ".local/share/applications/swayimg.desktop";
      source = "${pkgs.swayimg}/share/applications/swayimg.desktop";
    }
  ];

  allLinks = commonLinks ++ (if host.hostname != "slavenixostwo" then uiLinks else [ ]);

  # Generate ln commands
  linkCommands = lib.concatMapStringsSep "\n" (
    { target, source }:
    "mkdir -p $(dirname ${home}/${target}) && ln -sfn ${source} ${home}/${target}"
  ) allLinks;

  # ── Dconf settings ─────────────────────────────────────────

  dconfCommands = ''
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/cursor-theme "'Bibata-Original-Amber'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Dark'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'Catppuccin-Mocha-Standard-Blue-Dark'"
  '';

  activationScript = pkgs.writeShellScriptBin "dotfiles-activate" ''
    set -e
    ${linkCommands}
    ${dconfCommands}
  '';
in
{
  programs.dconf.enable = true;

  systemd.user.services.dotfiles-activation = {
    wantedBy = [ "default.target" ];
    before = [ "graphical-session-pre.target" ];
    after = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${activationScript}/bin/dotfiles-activate";
    };
    restartTriggers = [ activationScript ];
    restartIfChanged = true;
  };
}
