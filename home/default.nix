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

  programs.kitty = {
    enable = true;
    font = {
      name = "0xProto Nerd Font Mono";
      size = 16;
    };
    shellIntegration = {
      enableZshIntegration = true;
      mode = "no-cursor";
    };
    # themeFile = "base2tone-suburb-dark";
    themeFile = "ForestNight";
    settings = {
      cursor = "#f0c30f";
      cursor_text_color = "#f0c30f";
      cursor_shape = "underline";
      cursor_trail = 1;
      cursor_trail_decay = "0.3 0.6";
      background_opacity = 0.7;
      #     font-family = [
      #       "0xProto Nerd Font Mono"
      #       "JetBrainsMono Nerd Font"
      #       "Noto Sans Mono CJK SC"
      #     ];
    };
  };

  services.cliphist.enable = true;

  # services.mpd.enable = true;
  # services.mpd-mpris.enable = true;

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
