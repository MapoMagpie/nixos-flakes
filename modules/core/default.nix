{
  host,
  ...
}:
{
  imports = [
    ./network.nix
    ./environment.nix
    ./shells.nix
    ./fonts
    ./programs.nix
    ./user.nix
    ./xdgmime.nix
    ./overlays.nix
    ./dotfiles.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  nix.settings.auto-optimise-store = true;

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

  system.stateVersion = "24.11";
}
