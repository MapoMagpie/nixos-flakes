{ config, ... }:
{
  home.file.".config/yazi/plugins".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/filemanager/plugins";
  home.file.".config/yazi/theme.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/filemanager/theme.toml";
  home.file.".config/yazi/keymap.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/filemanager/keymap.toml";
  programs.yazi = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
    settings = {
      mgr = {
        ratio = [
          1
          4
          3
        ];
        show_hidden = false;
      };
      preview = {
        wrap = "no";
        tab_size = 2;
        max_width = 800;
      };
      open = {
        prepend_rules = [
          {
            name = "*.zip";
            use = [
              "extract"
              "reveal"
            ];
          }
        ];
      };
      plugin = {
        prepend_previewers = [
          {
            name = "*.zip";
            run = "archive";
          }
        ];
      };
    };
  };
}
