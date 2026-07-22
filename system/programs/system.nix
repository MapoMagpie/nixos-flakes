{
  pkgs,
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

  environment.systemPackages = with pkgs; [
    curl

    zip
    xz
    unzip
    p7zip
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
