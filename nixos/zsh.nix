{ host, ... }:
{
  system.userActivationScripts.zshrc = "touch .zshrc";
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histFile = "/home/${host.username}/.local/share/zsh/history";
    histSize = 100000;
    shellAliases = {
      ll = "eza -l";
      bos = "sudo nixos-rebuild switch --flake ~/nixos && notify-send 'nixos build succeeded'";
      nu = "nix flake update";
      kt = "kitty @ launch --type=os-window --cwd=current --copy-env";
      h = "hx .";
      y = "yazi_cwd";
    };
    # shellInit = ''
    # '';
    # eval "$(tv init zsh)"
    # autoload -U edit-command-line
    # zle -N edit-command-line
    # bindkey '^Xe' edit-command-line
    interactiveShellInit = ''
      source /home/${host.username}/nixos/home/misc/scripts/yazi_cwd.sh
      eval "$(atuin init zsh)"
      nd() {
        if [ -z "$1" ]; then
          nix develop -c zsh
        else
          nix develop ~/nixos#"$1" -c zsh
        fi
      }
    '';
    setOptions = [
      "EXTENDED_HISTORY"
      "HIST_IGNORE_ALL_DUPS"
      "HIST_IGNORE_DUPS"
      "HIST_IGNORE_SPACE"
      "SHARE_HISTORY"
    ];
  };
}
