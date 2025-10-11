{
  pkgs,
  ...
}:
{

  programs.zsh.enable = true;
  programs.wshowkeys.enable = true;
  programs.niri.enable = true;
  programs.git = {
    enable = true;
    # lfs.enable = true;
  };

  environment.systemPackages = with pkgs; [
    wget
    curl

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
    # ltrace # library call monitoring
    lsof # list open files

    sysstat
    ethtool
    pciutils # lspci

    ddcutil

    ntfs3g

    miniserve
    yazi
    helix
    ffmpeg
    imagemagick
    libavif
    mpv

    hyprpolkitagent
  ];
}
