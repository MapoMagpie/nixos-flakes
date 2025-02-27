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
    ./zsh.nix
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
    kitty
    bat
    wl-clipboard
    killall
    freerdp3
    swayimg
    rimedm.packages.${pkgs.system}.default
    gitui

    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
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
    userName = "MapoMagpie";
    userEmail = "zsyjk@live.cn";
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "catppuccin-mocha";
      font-size = 16;
      font-family = [
        "0xProto Nerd Font Mono"
        "JetBrainsMono Nerd Font"
        "Noto Sans Mono CJK SC"
      ];
      font-style = "Bold";
      background-opacity = 0.8;
      background-blur-radius = 20;
      window-decoration = false;
      cursor-style = "underline";
      cursor-style-blink = true;
      shell-integration-features = "no-cursor";
      keybind = [ "right_shift=ignore" ];
    };
  };

  services.cliphist.enable = true;

  # services.mpd.enable = true;
  services.mpd-mpris.enable = true;

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
