{
  homeDir,
  currDir,
  mkLinkCommands,
  pkgs,
  host,
  ...
}:
let
  # ── Text-based files (built into nix store) ─────────────────
  bashrc = pkgs.writeText "bashrc" ''
    enable -f ${pkgs.flyline}/lib/libflyline.so flyline
    flyline suggestions --auto-suggest true
    flyline mouse --mode disabled
    flyline key bind Ctrl+b always=moveLeftOneWord
    flyline key bind Ctrl+w always=moveRightOneWord
    flyline key bind Ctrl+h always=moveLeft
    flyline key bind Ctrl+l always=moveRight
    flyline create-prompt-widget custom --name STARSHIP --command "${currDir}/misc/scripts/shell_prompt.sh" --placeholder prev
    flyline create-prompt-widget custom --name PATHABBR --command "${currDir}/misc/scripts/path_abbr 40" --placeholder prev
    PS1='\e[02m[\t]\e[00m \e[01;04;32mPATHABBR\e[00m STARSHIP \n\e[01;95m⦊:\e[00m'
    PS1_FINAL='\e[02m[\t]-|\e[00m'
    shopt -s checkjobs
    eval "$(${pkgs.zoxide}/bin/zoxide init bash)"
    source ${currDir}/misc/scripts/yazi_cwd.sh
    source ${pkgs.git}/share/bash-completion/completions/git
    export KITTY_SHELL_INTEGRATION="enabled"
    source ${pkgs.kitty}/lib/kitty/shell-integration/bash/kitty.bash
    alias bos='nh os switch --ask --accept-flake-config ~/nixos && notify-send "nixos build succeeded"'
    alias h='hx .'
    alias kk='kitty @ launch --type=os-window --cwd=current --copy-env'
    alias kt='kitty @ launch --type=tab --cwd=current --copy-env'
    alias nu='nix flake update'
    alias y=yazi_cwd
    nd() {
      if [ -z "$1" ]; then
        nix develop
      else
        nix develop ~/nixos#"$1"
      fi
    }
    # Bash history (SAVEHIST is a zsh variable and has no effect in bash).
    # HISTSIZE limits the in-memory list; HISTFILESIZE limits the file.
    # Keep each shell's in-memory history independent. `history -a` persists
    # this shell's new entries without clearing and reloading its history.
    export HISTFILE="''${HISTFILE:-$HOME/.bash_history}"
    export HISTSIZE=100000
    export HISTFILESIZE=100000
    export HISTCONTROL=ignoredups:erasedups
    export HISTTIMEFORMAT='%F %T '
    shopt -s histappend
    export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
  '';

  # Login shells (TTY, ssh, sudo -i, desktop session) only read
  # /etc/profile + ~/.bash_profile and do NOT source ~/.bashrc. Without this
  # they would exit with default HISTSIZE/HISTFILESIZE=500 and no erasedups,
  # truncating ~/.bash_history back to <=500 entries. Source ~/.bashrc so the
  # same history settings apply everywhere.
  bashProfile = pkgs.writeText "bash_profile" ''
    if [ -f "$HOME/.bashrc" ]; then
      . "$HOME/.bashrc"
    fi
  '';

  gitConfig = pkgs.writeText "gitconfig" ''
    [user]
      name = "${host.git.userName}"
      email = "${host.git.userEmail}"
    [rerere]
      enable = true
      autoupdate = true
    [pull]
      rebase = true
    [diff]
      colorMoved = zebra
      algorithm = histogram
  '';

  link = [
    {
      target = ".bashrc";
      source = bashrc;
    }
    {
      target = ".bash_profile";
      source = bashProfile;
    }
    {
      target = ".config/git/config";
      source = gitConfig;
    }
    {
      target = ".config/yazi";
      source = "${currDir}/yazi";
    }
    {
      target = ".config/kitty";
      source = "${currDir}/kitty";
    }
    {
      target = ".config/television";
      source = "${currDir}/television";
    }
    {
      target = ".config/helix";
      source = "${currDir}/helix";
    }
  ];
  linkCommands = mkLinkCommands link;
in
linkCommands
