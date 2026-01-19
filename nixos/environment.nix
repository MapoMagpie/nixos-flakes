{ pkgs, ... }:
{
  environment = {
    shells = [ pkgs.zsh ];
    variables = {
      EDITOR = "hx";
      TERMINAL = "kitty";
      "QT_QPA_PLATFORM" = "wayland";
      "QT_QPA_PLATFORMTHEME" = "flatpak";
      "SKIM_DEFAULT_COMMAND" = "fd -d 6 -H -E node_modules -E .git -E '*.lock'";
    };
  };
}
