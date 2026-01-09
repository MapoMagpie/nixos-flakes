{
  pkgs,
  host,
  rimedm,
  helix,
  ...
}:
{

  programs.zsh.enable = true;
  programs.niri.enable = true;
  programs.git = {
    enable = true;
    # lfs.enable = true;
  };

  environment.systemPackages =
    with pkgs;
    [
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
      skim
      jq
      sd
      fd

      ffmpeg
      imagemagick
      libavif
      mpv

      file
      which
      tree
      btop
      showmethekey

      sysstat
      ethtool

      ddcutil

      ntfs3g

      gnome-keyring
      hyprpolkitagent

      libnotify

      yazi
      # helix
      helix.packages.${pkgs.stdenv.hostPlatform.system}.default
      miniserve
      telegram-desktop

      tldr
      bat
      wl-clipboard
      killall
      freerdp
      swayimg
      wf-recorder
      rimedm.packages.${pkgs.stdenv.hostPlatform.system}.default
      grim
      gitui

      slurp
      dragon-drop
    ]
    ++ (
      if host.hostname == "maponixos" then
        [
          gimp3
          kdePackages.kdenlive
          yt-dlp
          tsukimi
        ]
      else
        [ ]
    );
}
