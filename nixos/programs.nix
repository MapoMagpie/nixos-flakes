{ pkgs, niri, ... }:
{
  nixpkgs.overlays = [ niri.overlays.niri ];

  programs.zsh.enable = true;
  programs.wshowkeys.enable = true;

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  environment.systemPackages = with pkgs; [
    wget
    curl
    git

    zip
    xz
    unzip
    p7zip
    zstd

    ripgrep # recursively searches directories for a regex pattern
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    jq
    sd

    file
    which
    tree
    btop # replacement of htop/nmon

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    sysstat
    ethtool
    pciutils # lspci

    ddcutil

    miniserve
    yazi
    helix
    ffmpeg
    imagemagick
    mpv

    hyprpolkitagent
  ];
}
