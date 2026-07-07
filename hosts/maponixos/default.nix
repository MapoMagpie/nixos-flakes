{
  pkgs,
  ...
}:
let
  hostConfig = {
    screen = {
      w = 2560;
      h = 1440;
    };
    username = "mapomagpie";
    hostname = "maponixos";
    userDesc = "Mapo Magpie";
    userInitPass = "changepassword";
    openssh.authorizedKeys.keys = [ ];
    git = {
      userName = "MapoMagpie";
      userEmail = "zsyjk@live.cn";
    };
    upowerEnable = false;
    niriConfig = "config.kdl";
  };

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
  _module.args.host = hostConfig;

  imports = [
    ./hardware.nix
    ../../modules/core
    ../../modules/desktop
    # ../../modules/core/kvm.nix
    # ../../modules/vpn.nix
  ];

  nix.settings.trusted-users = [ hostConfig.username ];

  # fix nuphy air75 fn key not working
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=0
  '';

  users.users."${hostConfig.username}".packages = with pkgs; [
    gimp3
    chromium
    codex
    claude-code
    github-copilot-cli
    scrcpy
    telegramWrapped
  ];
}
