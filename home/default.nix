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
  ];
  # 注意修改这里的用户名与用户目录
  home.username = host.username;
  home.homeDirectory = "/home/${host.username}";

  # 直接将当前文件夹的配置文件，链接到 Home 目录下的指定位置
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # 递归将某个文件夹中的文件，链接到 Home 目录下的指定位置
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # 递归整个文件夹
  #   executable = true;  # 将其中所有文件添加「执行」权限
  # };

  # 直接以 text 的方式，在 nix 配置文件中硬编码文件内容
  # home.file.".xxx".text = ''
  #     xxx
  # '';

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

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
