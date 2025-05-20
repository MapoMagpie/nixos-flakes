{ config, ... }:
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
    completionInit = ''
      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey '^Xe' edit-command-line
    '';
    history = {
      size = 100000;
      path = "${config.xdg.dataHome}/zsh/history";
      extended = true;
      ignoreAllDups = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };
    historySubstringSearch = {
      enable = true;
      searchDownKey = [
        "^[[B"
        "$terminfo[kcud1]"
      ];
      searchUpKey = [
        "^[[A"
        "$terminfo[kcuu1]"
      ];
    };
    shellAliases = {
      ll = "eza -l";
      buildos = "sudo nixos-rebuild switch --flake ~/nixos && notify-send 'nixos build succeeded'";
      nd = "nix develop";
      h = "hx .";
      y = "yazi_cwd";
    };
    initContent = "source ${config.home.homeDirectory}/nixos/home/misc/scripts/yazi_cwd.sh";
  };

}
