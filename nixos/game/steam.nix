{ ... }:
{
  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
      env = {
        "LANG" = "zh_CN.utf8";
        "LC_ALL" = "zh_CN.utf8";
      };
      args = [
        "-W"
        "2560"
        "-H"
        "1440"
        "-w"
        "1920"
        "-h"
        "1080"
        "-e"
        "-f"
      ];
      steamArgs = [
        "-tenfoot"
        "-pipewire-dmabuf"
      ];
    };
  };
}
