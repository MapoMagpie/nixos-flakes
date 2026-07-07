{ ... }:
{
  system.userActivationScripts.zshrc = "touch .zshrc";
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = "";
    setOptions = [
      "EXTENDED_HISTORY"
      "HIST_IGNORE_ALL_DUPS"
      "HIST_IGNORE_DUPS"
      "HIST_IGNORE_SPACE"
      "SHARE_HISTORY"
    ];
  };
}
