# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  host,
  niri,
  ...
}:

{
  imports =
    [
      niri.nixosModules.niri
    ]
    ++ (
      if host.hostname == "maponixos" then
        [
          ./hardware-configuration-maponixos.nix
        ]
      else
        [ ]
    );
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

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = host.hostname; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # i18n.extraLocaleSettings = {
  #   LC_ADDRESS = "zh_CN.UTF-8";
  #   LC_IDENTIFICATION = "zh_CN.UTF-8";
  #   LC_MEASUREMENT = "zh_CN.UTF-8";
  #   LC_MONETARY = "zh_CN.UTF-8";
  #   LC_NAME = "zh_CN.UTF-8";
  #   LC_NUMERIC = "zh_CN.UTF-8";
  #   LC_PAPER = "zh_CN.UTF-8";
  #   LC_TELEPHONE = "zh_CN.UTF-8";
  #   LC_TIME = "zh_CN.UTF-8";
  # };

  fonts = {
    packages = with pkgs; [
      nerd-fonts._0xproto
      nerd-fonts._3270
      noto-fonts-emoji
      lxgw-wenkai
      lxgw-neoxihei
      lxgw-wenkai-tc
      lxgw-fusionkai
      lxgw-wenkai-screen
      sarasa-gothic
      # noto-fonts
      # noto-fonts-cjk-sans
      # noto-fonts-cjk-serif
      # maple-mono.truetype
      # Maple Mono NF (Ligature unhinted)
      # maple-mono.NF-unhinted
      # Maple Mono NF CN (Ligature unhinted)
      # maple-mono.NF-CN-unhinted
      # ark-pixel-font
      # maple-mono.CN
      # # Maple Mono CN (Ligature unhinted)
      # maple-mono.CN-unhinted
      # # Maple Mono NF CN (Ligature hinted)
      # maple-mono.NF-CN
      # # Maple Mono NF CN (Ligature unhinted)
      # maple-mono.NF-CN-unhinted
      # monocraft
      # material-design-icons
      (pkgs.stdenv.mkDerivation {
        name = "local_fonts";
        src = ../home/misc/fonts;
        installPhase = ''
          mkdir -p $out/share/fonts/truetype
          cp $src/*.{ttf,otf} $out/share/fonts/truetype/
        '';
      })
    ];
    enableDefaultPackages = true;
    fontDir.enable = true;
    fontconfig = {
      defaultFonts = {
        # serif = [
        #   "Noto Serif"
        #   "Noto Sans CJK SC"
        #   "Noto Sans CJK TC"
        # ];
        # sansSerif = [
        #   "Noto Sans"
        #   "Noto Sans CJK SC"
        #   "Noto Sans CJK TC"
        # ];
        # monospace = [
        #   "Noto Sans Mono"
        #   "Noto Sans Mono CJK SC"
        #   "Noto Sans Mono CJK TC"
        # ];
        # emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs.zsh.enable = true;
  programs.wshowkeys.enable = true;

  nixpkgs.overlays = [ niri.overlays.niri ];
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  security.polkit.enable = true;
  # xdg.portal.wlr.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${host.username}" = {
    isNormalUser = true;
    description = host.userDesc;
    initialPassword = host.userInitPass;
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "i2c"
    ];
    openssh.authorizedKeys.keys = host.openssh.authorizedKeys.keys;
  };

  nixpkgs.config.allowUnfree = true;

  # fix nuphy air75 fn key not working
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=0
  '';
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    # archives
    zip
    xz
    unzip
    p7zip
    zstd
    # utils
    ripgrep # recursively searches directories for a regex pattern
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    jq
    sd
    # misc
    file
    which
    tree
    btop # replacement of htop/nmon
    iftop # network monitoring
    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files
    # system toolst
    sysstat
    ethtool
    pciutils # lspci
    usbutils # lsusb

    ddcutil

    # sddm theme
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtsvg
    libsForQt5.qt5.qtbase
    libsForQt5.qt5.qtgraphicaleffects
    sddm-sugar-dark

    miniserve
    yazi
    helix
    mpv
    nix-output-monitor

    hyprpolkitagent
  ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sugar-dark";
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22
    8080
    41021
  ];
  services.openssh = {
    enable = true;
    settings = {
      UseDns = false;
      UsePAM = false;
      X11Forwarding = true;
    };
    extraConfig = ''
      ClientAliveInterval 60
      ClientAliveCountMax 3
    '';
  };
  services = {
    # dbus.packages = [pkgs.gcr];
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
