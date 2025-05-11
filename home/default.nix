{
  pkgs,
  host,
  rimedm,
  ...
}:
{
  imports = [
    ./ui
    ./filemanager
    ./term
    ./fcitx5
    ./browser
    ./code
    ./misc
  ] ++ (if host.hostname == "maponixos" then [ ./game ] else [ ]);

  home.username = host.username;
  home.homeDirectory = "/home/${host.username}";

  home.packages = with pkgs; [
    gh
    git-credential-manager
    tldr
    telegram-desktop
    bat
    wl-clipboard
    killall
    freerdp3
    swayimg
    rimedm.packages.${pkgs.system}.default
    gitui

    gnome-keyring
    slurp
    libnotify
    grim
    wf-recorder
    xdragon
    showmethekey

    ffmpeg
    imagemagick
    gimp
  ];

  programs.git = {
    enable = true;
    userName = host.git.userName;
    userEmail = host.git.userEmail;
  };

  services.cliphist = {
    enable = true;
    allowImages = true;
    extraOptions = [
      "-max-dedupe-search"
      "500"
      "-max-items"
      "5000"
    ];
  };

  # services.mpd.enable = true;
  # services.mpd-mpris.enable = true;

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
