{ ... }:
{
  home.file.".config/fuzzel/merge_window_info.sh".source = ./merge_window_info.sh;
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "Monocraft:weight=bold:size=14";
        icons-enabled = "no";
        # terminal = "ghostty";
        show-actions = "no";
        lines = 20;
        width = 60;
        tabs = 5;
        horizontal-pad = 10;
        inner-pad = 5;
        line-height = 16;
        letter-spacing = 0;
      };
      colors = {
        background = "212121ee";
        text = "f1c30fff";
        match = "cb4b16ff";
        border = "f1c30fff";
      };
      border = {
        width = 2;
        radius = 7;
      };
    };
  };
}
