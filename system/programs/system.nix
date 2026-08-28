{
  pkgs,
  host,
  ...
}:
{

  programs = {
    git.enable = true;
  };
  programs.bash = {
    enable = true;
    completion.enable = false;
    # interactiveShellInit = ''
    #   enable -f ${pkgs.flyline}/lib/libflyline.so flyline
    # '';
  };
  programs.nh = {
    enable = true;
    clean.enable = true;
    # clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/${host.username}/nixos"; # sets NH_OS_FLAKE variable for you
  };

  environment.systemPackages = with pkgs; [
    curl

    zip
    xz
    unzip
    _7zz
    _7zip-zstd
    zstd
    ouch

    ripgrep
    eza
    fzf
    jq
    sd
    fd
    television

    ffmpeg
    libavif
    libnotify

    file
    which
    tree
    btop

    sysstat
    ethtool
    socat

    ddcutil

    ntfs3g

    gnome-keyring

    yazi
    # helix (from overlay, pre-built runtime avoids eval overhead)
    helix
    miniserve

    tldr
    bat
    delta
    killall

    wl-clipboard

    python3
    xxd
    gh
  ];
}
