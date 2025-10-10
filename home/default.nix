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
  ]
  ++ (if host.hostname == "maponixos" then [ ./game ] else [ ]);

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

    gimp3
    kdePackages.kdenlive
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

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/zip" = [ "7z.desktop" ];
      "application/7z" = [ "7z.desktop" ];
      "application/7z-compressed" = [ "7z.desktop" ];
      "application/octet-stream" = [ "7z.desktop" ];
      "image/png" = [ "swayimg.desktop" ];
      "image/jpeg" = [ "swayimg.desktop" ];
      "image/bmp" = [ "swayimg.desktop" ];
      "image/gif" = [ "swayimg.desktop" ];
      "image/webp" = [ "swayimg.desktop" ];
      "image/avif" = [ "swayimg.desktop" ];
      "image/svg+xml" = [ "swayimg.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/chrome" = [ "firefox.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "application/x-extension-htm" = [ "firefox.desktop" ];
      "application/x-extension-html" = [ "firefox.desktop" ];
      "application/x-extension-shtml" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];
      "application/x-extension-xhtml" = [ "firefox.desktop" ];
      "application/x-extension-xht" = [ "firefox.desktop" ];
      "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop;" ];
      "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop;" ];
    };
    associations.added = {
      "application/zip" = [ "7z.desktop" ];
      "application/7z" = [ "7z.desktop" ];
      "application/7z-compressed" = [ "7z.desktop" ];
      "application/octet-stream" = [ "7z.desktop" ];
      "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop;" ];
      "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop;" ];
      "x-scheme-handler/http" = [ "firefox.desktop;" ];
      "x-scheme-handler/https" = [ "firefox.desktop;" ];
      "x-scheme-handler/chrome" = [ "firefox.desktop;" ];
      "text/html" = [ "firefox.desktop;" ];
      "application/x-extension-htm" = [ "firefox.desktop;" ];
      "application/x-extension-html" = [ "firefox.desktop;" ];
      "application/x-extension-shtml" = [ "firefox.desktop;" ];
      "application/xhtml+xml" = [ "firefox.desktop;" ];
      "application/x-extension-xhtml" = [ "firefox.desktop;" ];
      "application/x-extension-xht" = [ "firefox.desktop;" ];

    };
  };

  # services.mpd.enable = true;
  # services.mpd-mpris.enable = true;

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
