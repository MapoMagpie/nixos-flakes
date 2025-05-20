hostname:
let
  host =
    if hostname == "maponixos" then
      {
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
      }
    else
      {
        screen = {
          w = 1920;
          h = 1080;
        };
        username = "mapomagpie";
        hostname = "slavenixos";
        userDesc = "Mapo Magpie Slave";
        userInitPass = "changepassword";
        hardwareModule = ./hardware/hardware-configuration-slavenixos.nix;
        openssh.authorizedKeys.keys = [ ];
        git = {
          userName = "MapoMagpie";
          userEmail = "zsyjk@live.cn";
        };
      };
in
host
