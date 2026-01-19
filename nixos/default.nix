{
  host,
  ...
}:

{
  imports = [
    ./fonts
    ./network.nix
    ./portal.nix
    ./programs.nix
    ./xdgmime.nix
    ./sddm.nix
    ./user.nix
    ./zsh.nix
    ./vpn.nix
    ./environment.nix
    ./fcitx.nix
    host.hardwareModule
  ]

  ++ (
    if host.hostname == "maponixos" then
      [
        ./game
        # ./kvm.nix
      ]
    else
      [ ]
  );

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.trusted-users = [ host.username ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  nix.settings.auto-optimise-store = true;

  hardware.i2c.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # fix nuphy air75 fn key not working
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=0
  '';

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocales = [
    "zh_CN.UTF-8/UTF-8"
    "zh_CN/GB2312"
    "zh_TW.UTF-8/UTF-8"
    "zh_TW.EUC-TW/EUC-TW"
    "zh_TW/BIG5"
    "ja_JP.UTF-8/UTF-8"
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  security.polkit.enable = true;
  security.pam.services.swaylock = { };

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
