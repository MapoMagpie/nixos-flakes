hostname:
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
    openssh.authorizedKeys.keys = [ ];
    git = {
      userName = "MapoMagpie";
      userEmail = "zsyjk@live.cn";
    };
    hardware = ./hardware-mapo.nix;
    upowerEnable = false;
    enable_ui = true;
    enable_ui_master = true;
    enable_game = true;
    enable_server = false;
  }
else if hostname == "slavenixos" then
  {
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
    hardware = ./hardware-slave.nix;
    upowerEnable = true;
    enable_ui = true;
    enable_ui_master = false;
    enable_game = false;
    enable_server = false;
  }
else if hostname == "slavenixostwo" then
  {
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
    hardware = ./hardware-slavetwo.nix;
    upowerEnable = true;
    enable_ui = false;
    enable_ui_master = false;
    enable_game = false;
    enable_server = true;
  }
else
  { }
