{
  pkgs,
  host,
  ...
}:
{
  imports = [
    host.hardware
    ./network.nix
    ./fonts.nix
    ./xdgmime.nix
    ../pkgs/overlays.nix
    ./programs
    ../home
  ]
  ++ (if host.enable_server then [ ./server ] else [ ]);

  users.users."${host.username}" = {
    isNormalUser = true;
    description = host.userDesc;
    initialPassword = host.userInitPass;
    shell = pkgs.bash;
    extraGroups = [
      "networkmanager"
      "wheel"
      "i2c"
      "libvirtd"
    ];
    openssh.authorizedKeys.keys = host.openssh.authorizedKeys.keys;
  };

  environment = {
    variables = {
      EDITOR = "hx";
      PAGER = "bat";
      TERMINAL = "kitty";
    };
  };

  nix.settings = {
    trusted-users = [ host.username ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  hardware.i2c.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Time zone
  time.timeZone = "Asia/Shanghai";

  # Internationalisation
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocales = [
    "zh_CN.UTF-8/UTF-8"
    "zh_CN/GB2312"
    "zh_TW.UTF-8/UTF-8"
    "zh_TW.EUC-TW/EUC-TW"
    "zh_TW/BIG5"
    "ja_JP.UTF-8/UTF-8"
  ];

  # Keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  security.polkit.enable = true;

  nixpkgs.config.allowUnfree = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.upower.enable = host.upowerEnable;
  services.power-profiles-daemon.enable = host.upowerEnable;

  hardware.bluetooth.enable = true;

  hardware.amdgpu = {
    initrd.enable = true;
    opencl.enable = true;
  };

  boot.extraModprobeConfig =
    if host.hostname == "maponixos" then
      ''
        options hid_apple fnmode=0
      ''
    else
      "";

  system.stateVersion = "24.11";
}
