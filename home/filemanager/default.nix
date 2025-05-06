{ config, ... }:
{

  home.file.".config/yazi/plugins".source = config.lib.file.mkOutOfStoreSymlink ./plugins;
  home.file.".config/yazi/theme.toml".source = config.lib.file.mkOutOfStoreSymlink ./theme.toml;
  home.file.".config/yazi/keymap.toml".source = config.lib.file.mkOutOfStoreSymlink ./keymap.toml;
  programs.yazi = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
    settings = {
      manager = {
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
