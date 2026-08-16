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
      # 这会导致`firefox`有一个左上角的130`px padding`，使一些`popup`错位
      # https://github.com/vinceliuice/Colloid-gtk-theme/blob/6c2dc65865628bda9fdc8157a30cd5eda6fd41f9/src/other/firefox/chrome/Colloid/parts/csd.css#L31
      # (colloid-gtk-theme.override { themeVariants = [ "pink" ]; }) # 装成 Colloid-Pink-Dark
      cliphist
      dgop
      quickshell
      # dms-shell
      # matugen
      firefox
      swayimg
      freerdp
      slurp
      telegramWrapped
      wayland-pipewire-idle-inhibit
      swayidle
    ]
    ++ (
      if host.enable_ui_master then
        [
          gimp3
          chromium
          codex
          github-copilot-cli
          scrcpy
          pi-coding-agent
        ]
      else
        [ ]
    );
}
