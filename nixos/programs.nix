{
  pkgs,
  rimedm,
  helix,
  ...
}:
{

  programs = {
    zsh.enable = true;
    git.enable = true;
  };

  environment.systemPackages = with pkgs; [
    wget
    curl

    zip
    xz
    unzip
    p7zip
    zstd

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
    # helix
    helix.packages.${pkgs.stdenv.hostPlatform.system}.default
    miniserve

    tldr
    bat
    delta
    killall
    rimedm.packages.${pkgs.stdenv.hostPlatform.system}.default

    wl-clipboard
  ];
}
