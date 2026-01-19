{ pkgs, host, ... }:
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
      kt = "SHELL=zsh kitty --detach";
      h = "hx .";
      y = "yazi_cwd";
    };
    # shellInit = ''
    # '';
    interactiveShellInit = ''
      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey '^Xe' edit-command-line
      source ${pkgs.skim}/share/skim/completion.zsh
      source ${pkgs.skim}/share/skim/key-bindings.zsh
      source /home/${host.username}/nixos/home/misc/scripts/yazi_cwd.sh
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
