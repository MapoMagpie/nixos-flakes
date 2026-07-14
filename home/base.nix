{
  homeDir,
  currDir,
  mkLineCommands,
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
    flyline key bind Ctrl+j always=fuzzyHistorySelectNext+tabCompletionMoveDown
    flyline key bind Ctrl+k always=fuzzyHistorySelectPrev+tabCompletionMoveUp
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
    alias bos='sudo nixos-rebuild switch --flake ~/nixos && notify-send "nixos build succeeded"'
    alias h='hx .'
    alias kk='kitty @ launch --type=os-window --cwd=current --copy-env'
    alias kt='kitty @ launch --type=tab --cwd=current --copy-env'
    alias nu='nix flake update'
    alias y=yazi_cwd
    nd() {
      if [ -z "$1" ]; then
        source <(nix print-dev-env)
      else
        source <(nix print-dev-env ~/nixos#"$1")
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
  linkCommands = mkLineCommands link;
  # ── Dconf settings ─────────────────────────────────────────
in
linkCommands
