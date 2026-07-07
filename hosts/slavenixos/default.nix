{
  pkgs,
  ...
}:
let
  hostConfig = {
    screen = {
      w = 1920;
      h = 1080;
    };
    username = "mapomagpie";
    hostname = "slavenixos";
    userDesc = "Mapo Magpie Slave";
    userInitPass = "changepassword";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHujke7fBecvwbiBDr2FgV6clGXFDCxSeHxvK5Z0tQjv mapomagpie@kamonixos"
    ];
    git = {
      userName = "MapoMagpie";
      userEmail = "zsyjk@live.cn";
    };
    upowerEnable = true;
    niriConfig = "config_slave.kdl";
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

  users.users."${hostConfig.username}".packages = [
    telegramWrapped
  ];
}
