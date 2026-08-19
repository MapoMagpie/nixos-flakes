{ pkgs, host, ... }:
let
  telegramWrapped = pkgs.symlinkJoin {
    name = "telegram-desktop";
    paths = [ pkgs.telegram-desktop ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/Telegram --set QT_QPA_PLATFORMTHEME flatpak
      # org.telegram.desktop.desktop 带 DBusActivatable=true：app launcher 通过
      # GIO 启动时走 D-Bus 激活，而不是执行桌面文件的 Exec 行。D-Bus 激活按
      # share/dbus-1/services/org.telegram.desktop.service 里的 Exec 拉起进程，
      # 默认 symlinkJoin 会把该 service 文件指向 base 包里未包装的二进制，
      # 导致从 launcher 启动时吃不到 QT_QPA_PLATFORMTHEME。
      # 这里改写为指向包装后二进制（$out/bin/Telegram）的真实文件。
      rm -f $out/share/dbus-1/services/org.telegram.desktop.service
      printf '%s\n' \
        '[D-BUS Service]' \
        'Name=org.telegram.desktop' \
        "Exec=$out/bin/Telegram" \
        > $out/share/dbus-1/services/org.telegram.desktop.service
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
      # telegram-desktop
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
          deepseek-harness
        ]
      else
        [ ]
    );
}
