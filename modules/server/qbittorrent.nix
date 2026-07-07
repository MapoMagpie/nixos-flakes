{ host, ... }:
{
  users.users."${host.username}".extraGroups = [
    "qbittorrent"
    "qui"
  ];

  environment.etc."qui-secret".text = "eeee125639fa03da0428c17b0f1ea5092281f02a98db73bd0606bd929fdbe5a9";
  services.qui = {
    enable = true;
    openFirewall = true;
    settings = {
      # logLevel = "DEBUG";
      metricsEnabled = true;
      host = "0.0.0.0";
      port = 2999;
    };
    secretFile = "/etc/qui-secret";
  };
  services.qbittorrent = {
    enable = true;
    webuiPort = 1999;
    openFirewall = true;

    torrentingPort = 41999;
    serverConfig = {
      # 第一次启动必须接受法律声明
      LegalNotice.Accepted = true;

      Preferences.WebUI = {
        LocalHostAuth = true; # 允许局域网访问
        Username = "mapo";
        Password_PBKDF2 = "@ByteArray(rHBvWfng1jZQ0ykFg0JheQ==:c8CS0TWz3wh4QFhaG6bXdetAKp5iUsZvr80yavzTPmv5wqiDeYAXmWlHQ+HuvbDDAYw7ossH+sKzxfkG55AfHQ==)"; # 用官方工具生成
        AlternativeUIEnabled = true;
        # RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
      };
      Preferences.Queueing = {
        MaxActiveDownloads = 10;
        MaxActiveUploads = 200;
        MaxActiveTorrents = 200;
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
