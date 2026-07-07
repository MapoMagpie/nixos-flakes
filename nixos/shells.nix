{ ... }:
{
  programs.bash = {
    enable = true;
    completion.enable = false;
    # interactiveShellInit = ''
    #   enable -f ${pkgs.flyline}/lib/libflyline.so flyline
    # '';
  };
  programs.zsh = {
    enable = false;
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
