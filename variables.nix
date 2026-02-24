hostname:
let
  host = {
    "maponixos" = {
      screen = {
        w = 2560;
        h = 1440;
      };
      username = "mapomagpie";
      hostname = "maponixos";
      userDesc = "Mapo Magpie";
      userInitPass = "changepassword";
      hardwareModule = ./hardware/hardware-configuration-maponixos.nix;
      openssh.authorizedKeys.keys = [ ];
      git = {
        userName = "MapoMagpie";
        userEmail = "zsyjk@live.cn";
      };
      upowerEnable = false;
    };
    "slavenixos" = {
      screen = {
        w = 1920;
        h = 1080;
      };
      username = "mapomagpie";
      hostname = "slavenixos";
      userDesc = "Mapo Magpie Slave";
      userInitPass = "changepassword";
      hardwareModule = ./hardware/hardware-configuration-slavenixos.nix;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHujke7fBecvwbiBDr2FgV6clGXFDCxSeHxvK5Z0tQjv mapomagpie@kamonixos"
      ];
      git = {
        userName = "MapoMagpie";
        userEmail = "zsyjk@live.cn";
      };
      upowerEnable = true;
    };
    "slavenixostwo" = {
      screen = {
        w = 1920;
        h = 1080;
      };
      username = "mapomagpie";
      hostname = "slavenixostwo";
      userDesc = "Mapo Magpie Slave Two";
      userInitPass = "changepassword";
      hardwareModule = ./hardware/hardware-configuration-slavenixostwo.nix;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHujke7fBecvwbiBDr2FgV6clGXFDCxSeHxvK5Z0tQjv mapomagpie@kamonixos"
      ];
      git = {
        userName = "MapoMagpie";
        userEmail = "zsyjk@live.cn";
      };
      upowerEnable = true;
    };
  };
in
host.${hostname}
