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

  zshrc = pkgs.writeText "zshrc" ''
    eval "$(${pkgs.starship}/bin/starship init zsh)"
    eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
    eval "$(${pkgs.atuin}/bin/atuin init zsh)"
    alias -- bos='sudo nixos-rebuild switch --flake ~/nixos && notify-send "nixos build succeeded"'
    alias -- h='hx .'
    alias -- kt='kitty @ launch --type=os-window --cwd=current --copy-env'
    alias -- nu='nix flake update'
    alias -- y=yazi_cwd
    source ${nixosDir}/home/misc/scripts/yazi_cwd.sh
    yazi_widget() { BUFFER="yazi_cwd"; zle accept-line }
    zle -N yazi_widget
    bindkey '^e' yazi_widget
    nd() {
      if [ -z "$1" ]; then
        nix develop -c zsh
      else
        nix develop ~/nixos#"$1" -c zsh
      fi
    }
    SAVEHIST=100000
    HISTSIZE=100000
    HISTFILE=${home}/.local/share/zsh/history
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
      target = ".zshrc";
      source = zshrc;
    }
    {
      target = ".config/git/config";
      source = gitConfig;
    }
    {
      target = ".config/yazi";
      source = "${../home/yazi}";
    }
    {
      target = ".config/kitty";
      source = "${../home/kitty}";
    }
    {
      target = ".config/starship.toml";
      source = "${../home/starship/starship.toml}";
    }
    {
      target = ".config/television";
      source = "${../home/television}";
    }
    {
      target = ".config/helix";
      source = "${../home/helix}";
    }
  ];
  # nixfmt:enable

  uiLinks = [
    # ── maid/ui.nix ──
    {
      target = ".mozilla/firefox/profiles.ini";
      source = "${../home/firefox/profiles.ini}";
    }
    {
      target = ".mozilla/firefox/mapomagpie/user.js";
      source = "${../home/firefox/user.js}";
    }
    {
      target = ".mozilla/firefox/mapomagpie/chrome";
      source = "${nixosDir}/external/firefox-compact-ui";
    }
    {
      target = ".config/niri/config.kdl";
      source = if host.hostname == "maponixos" then "${../home/niri/config.kdl}" else "${../home/niri/config_slave.kdl}";
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
      source = "${../home/swayimg/init.lua}";
    }
    # {
    #   target = ".config/swaylock/config";
    #   source = "${nixosDir}/home/swaylock/config";
    # }
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
