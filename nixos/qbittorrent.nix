{ pkgs, ... }:
{
  services.qbittorrent = {
    enable = true;
    webuiPort = 1999;
    openFirewall = true;

    serverConfig = {
      # 第一次启动必须接受法律声明
      LegalNotice.Accepted = true;

      Preferences.WebUI = {
        LocalHostAuth = false; # 允许局域网访问
        Username = "mapo";
        Password_PBKDF2 = "@ByteArray(FdG+dhQZh1tT6O9Pld10VQ==:V6yM0sHBeIJqao+yLxu3w2bXQUoAAXrhpgq39qKE8pziFgoPz39GWMCiPqvRTBMKfpQ1IRBg/4vMPlFsaXUubw==)"; # 用官方工具生成
        AlternativeUIEnabled = true;
        RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
      };

      # 下载设置
      Preferences.Downloads = {
        SavePath = "/mnt/hdd1/bt";
        TempPathEnabled = true;
        TempPath = "/mnt/hdd1/bt/.incomplete";
      };

      # 新版 qBittorrent（4.x+）也推荐同时设置 Session（兼容性更好）
      BitTorrent.Session = {
        DefaultSavePath = "/mnt/hdd1/bt";
      };
    };
  };

  # 自动创建下载目录并设置权限
  systemd.tmpfiles.rules = [
    "d /mnt/hdd1/bt           2770 qbittorrent qbittorrent -"
    "d /mnt/hdd1/bt/.incomplete 2770 qbittorrent qbittorrent -"
  ];
}
