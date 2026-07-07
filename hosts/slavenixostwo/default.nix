{
  config,
  lib,
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
    hostname = "slavenixostwo";
    userDesc = "Mapo Magpie Slave Two";
    userInitPass = "changepassword";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHujke7fBecvwbiBDr2FgV6clGXFDCxSeHxvK5Z0tQjv mapomagpie@kamonixos"
    ];
    git = {
      userName = "MapoMagpie";
      userEmail = "zsyjk@live.cn";
    };
    upowerEnable = true;
  };
in
{
  _module.args.host = hostConfig;

  imports = [
    ./hardware.nix
    ../../modules/core
    ../../modules/server
    ../../modules/core/kvm.nix
  ];

  nix.settings.trusted-users = [ hostConfig.username ];
}
