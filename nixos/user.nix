{
  pkgs,
  host,
  ...
}:
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

  commonUserPkgs = with pkgs; [
    zoxide
    starship
    nixd
    nixfmt
    gitui
    yt-dlp
    kitty
  ];

  uiPkgs = with pkgs; [
    mpvpaper
    sway-audio-idle-inhibit
    bibata-cursors
    adwaita-icon-theme
    papirus-icon-theme
    catppuccin-gtk
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
  ];

  maponixosExtraPkgs = with pkgs; [
    gimp3
    chromium
    codex
    claude-code
    github-copilot-cli
    scrcpy
    telegramWrapped
  ];

  slavenixosExtraPkgs = [
    telegramWrapped
  ];
in
{
  users.users."${host.username}" = {
    isNormalUser = true;
    description = host.userDesc;
    initialPassword = host.userInitPass;
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "i2c"
      "libvirtd"
    ]
    ++ (
      if host.hostname == "slavenixostwo" then
        [
          "qbittorrent"
          "qui"
        ]
      else
        [ ]
    );
    openssh.authorizedKeys.keys = host.openssh.authorizedKeys.keys;
    packages =
      commonUserPkgs
      ++ (if host.hostname == "slavenixostwo" then [ ] else uiPkgs)
      ++ (
        if host.hostname == "maponixos" then
          maponixosExtraPkgs
        else if host.hostname == "slavenixos" then
          slavenixosExtraPkgs
        else
          [ ]
      );
  };

}
