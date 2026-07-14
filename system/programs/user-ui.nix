{ pkgs, host, ... }:
let
  telegramWrapped = pkgs.symlinkJoin {
    name = "telegram-desktop";
    paths = [ pkgs.telegram-desktop ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/Telegram \
        --set QT_QPA_PLATFORMTHEME flatpak
    '';
  };
in
{
  users.users."${host.username}".packages =
    with pkgs;
    [
      bibata-cursors
      adwaita-icon-theme
      papirus-icon-theme
      nordic
      cliphist
      fuzzel
      dgop
      quickshell
      dms-shell
      matugen
      firefox
      swayimg
      freerdp
      slurp
      telegramWrapped
    ]
    ++ (
      if host.enable_ui_master then
        [
          gimp3
          chromium
          codex
          claude-code
          github-copilot-cli
          scrcpy
        ]
      else
        [ ]
    );
}
