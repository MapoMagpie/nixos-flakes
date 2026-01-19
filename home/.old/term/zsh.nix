{ pkgs, config, ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = false;
      env_var.YAZI_LEVEL = {
        symbol = "🆈";
        variable = "YAZI_LEVEL";
        format = "$symbol ";
        disabled = false;
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 100000;
      path = "${config.xdg.dataHome}/zsh/history";
      extended = true;
      ignoreAllDups = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };
    shellAliases = {
      ll = "eza -l";
      bos = "sudo nixos-rebuild switch --flake ~/nixos && notify-send 'nixos build succeeded'";
      nu = "nix flake update";
      kt = "SHELL=zsh kitty --detach";
      h = "hx .";
      y = "yazi_cwd";
    };
    initContent = ''
      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey '^Xe' edit-command-line
      source ${config.home.homeDirectory}/nixos/home/misc/scripts/yazi_cwd.sh
      source ${pkgs.skim}/share/skim/completion.zsh
      source ${pkgs.skim}/share/skim/key-bindings.zsh
      nd() {
        if [ -z "$1" ]; then
          nix develop -c zsh
        else
          nix develop ~/nixos#"$1" -c zsh
        fi
      }
    '';
  };

}
