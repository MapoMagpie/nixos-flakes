{
  host,
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
  ];

  home.username = host.username;
  home.homeDirectory = "/home/${host.username}";

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = host.git.userName;
        email = host.git.userEmail;
      };
    };
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
