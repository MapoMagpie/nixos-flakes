{
  config,
  lib,
  pkgs,
  host,
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

  # ── Symlink rules ───────────────────────────────────────────
  # nixfmt:disable
  commonLinks = [
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

  allLinks = commonLinks ++ config.dotfiles.extraLinks;

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
  options.dotfiles.extraLinks = lib.mkOption {
    type = lib.types.listOf (
      lib.types.submodule {
        options = {
          target = lib.mkOption { type = lib.types.str; };
          source = lib.mkOption { type = lib.types.either lib.types.str lib.types.package; };
        };
      }
    );
    default = [ ];
    description = "Extra symlinks to create during dotfiles activation (added by role modules)";
  };

  config = {
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
  };
}
