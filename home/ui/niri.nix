{
  niri,
  pkgs,
  config,
  ...
}:
{
  home.file.".config/swww/images".source = ./images;

  imports = [ niri.homeModules.niri ];

  programs.niri = {
    enable = true;
    settings = {
      prefer-no-csd = true;
      environment = {
        QT_QPA_PLATFORM = "wayland";
        EDITOR = "hx";
        TERMINAL = "ghostty";
      };
      spawn-at-startup = [
        { command = [ "waybar" ]; }
        {
          command = [
            "fcitx5"
            "-rd"
          ];
        }
        {
          command = [
            "systemctl"
            "--user"
            "start"
            "hyprpolkitagent"
          ];
        }
        { command = [ "swww-daemon" ]; }
        {
          command = [
            "swww"
            "img"
            "${config.xdg.configHome}/swww/images/4.png"
            "--transition-type"
            "center"
          ];
        }
      ];
      input = {
        keyboard = {
          repeat-delay = 400;
          repeat-rate = 50;
        };
        focus-follows-mouse.enable = true;
      };
      layout = {
        gaps = 1;
        center-focused-column = "never";
        # center-focused-column = "on-overflow";
        # "always-center-single-column" = false;
        preset-column-widths = [
          { proportion = 1.0 / 3.0; }
          { proportion = 1.5 / 3.0; }
          { proportion = 2.0 / 3.0; }
          { proportion = 3.0 / 3.0; }
        ];
        preset-window-heights = [
          { proportion = 1.0 / 3.0; }
          { proportion = 1.5 / 3.0; }
          { proportion = 2.0 / 3.0; }
          { proportion = 3.0 / 3.0; }
        ];
        # "default-column-width" = {};
        # "default-column-height" = {};
        focus-ring = {
          enable = true;
          width = 2;
          active = {
            color = "#f0c30f";
          };
        };
        border = {
          enable = false;
        };
        insert-hint = {
          enable = true;
          display = {
            color = "#ffc87f80";
          };
        };
        struts = {
          left = 2;
          right = 2;
          top = 6;
          bottom = 6;
        };
      };
      binds = with config.lib.niri.actions; {
        # "Mod+Q".action = do-screen-transition;
        "Mod+Space".action = spawn "fuzzel";
        "Mod+Return".action = spawn "ghostty";
        "Mod+Q".action = close-window;
        "Mod+Shift+Q".action = quit;
        "Mod+H".action = focus-column-or-monitor-left;
        "Mod+L".action = focus-column-or-monitor-right;
        "Mod+J".action = focus-window-or-monitor-down;
        "Mod+K".action = focus-window-or-monitor-up;
        "Mod+WheelScrollUp".action = focus-window-up-or-column-left;
        "Mod+WheelScrollDown".action = focus-window-down-or-column-right;
        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+L".action = move-column-right;
        "Mod+Shift+J".action = move-window-down;
        "Mod+Shift+K".action = move-window-up;
        "Mod+Shift+U".action = consume-or-expel-window-left;
        "Mod+Shift+I".action = consume-or-expel-window-right;
        "Mod+Shift+O".action = swap-window-left;
        "Mod+Shift+P".action = swap-window-right;
        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;
        "Mod+6".action = focus-workspace 6;
        "Mod+7".action = focus-workspace 7;
        "Mod+8".action = focus-workspace 8;
        "Mod+9".action = focus-workspace 9;
        "Mod+Shift+1".action = move-window-to-workspace 1;
        "Mod+Shift+2".action = move-window-to-workspace 2;
        "Mod+Shift+3".action = move-window-to-workspace 3;
        "Mod+Shift+4".action = move-window-to-workspace 4;
        "Mod+Shift+5".action = move-window-to-workspace 5;
        "Mod+Shift+6".action = move-window-to-workspace 6;
        "Mod+Shift+7".action = move-window-to-workspace 7;
        "Mod+Shift+8".action = move-window-to-workspace 8;
        "Mod+Shift+9".action = move-window-to-workspace 9;
        "Mod+Alt+H".action = set-window-width "-10%";
        "Mod+Alt+L".action = set-window-width "+10%";
        "Mod+Alt+J".action = set-window-height "+10%";
        "Mod+Alt+K".action = set-window-height "-10%";
        "Mod+Alt+O".action = reset-window-height;
        "Mod+R".action = switch-preset-column-width;
        "Mod+Shift+R".action = switch-preset-window-height;
        "Mod+F".action = maximize-column;
        "Mod+Shift+Slash".action = show-hotkey-overlay;
        "Mod+T".action = toggle-window-floating;
        "Mod+Shift+T".action = switch-focus-between-floating-and-tiling;
        "Mod+G".action = center-column;
        "Mod+V".action = spawn "bash" "-c" "cliphist list | fuzzel -d | cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy";
        "Mod+W".action = spawn "bash" "-c" "niri msg windows | ${config.home.homeDirectory}/.config/fuzzel/merge_window_info.sh | fuzzel -d | cut -d '/' -f1 | xargs -I {} niri msg action focus-window --id {}";
        "Mod+S".action = spawn "bash" "-c" ''slurp > /tmp/geometry && notify-send "$(cat /tmp/geometry)"'';
        "Mod+Shift+S".action = spawn "bash" "-c" ''sleep 3 && grim -g "$(cat /tmp/geometry)" ${config.home.homeDirectory}/Pictures/screenshots/grim_$(date +"%Y%m%d_%H%M%S").png && notify-send "Screenshot Done"'';
        "Mod+Shift+E".action = spawn "bash" "-c" ''notify-send "wf-recorder started" && wf-recorder -g "$(cat /tmp/geometry)" -r 30 -f ${config.home.homeDirectory}/Videos/screenshots/rec_$(date +"%Y%m%d_%H%M%S").mp4 && notify-send "wf-recorder done"'';
        "Mod+Alt+E".action = spawn "killall" "-INT" "wf-recorder";
      };
      window-rules = [
        # no background of border
        {
          matches = [
            { app-id = "ghostty$"; }
            { app-id = "^swayimg$"; }
          ];
          draw-border-with-background = false;
        }
        # dragon drag-and-drop
        {
          matches = [
            { app-id = "^dragon$"; }
          ];
          open-floating = true;
          open-focused = false;
          default-floating-position = {
            relative-to = "bottom-left";
            x = 10;
            y = 10;
          };
        }
        # swayimg
        {
          matches = [
            { app-id = "^swayimg$"; }
          ];
          open-floating = true;
          default-column-width = {
            proportion = 1.0;
          };
          default-window-height = {
            proportion = 1.0;
          };
        }
        # floating and size and bottom-right
        {
          matches = [
            {
              app-id = "^firefox$";
              title = "Picture-in-Picture";
            }
            { app-id = "^mpv$"; }
          ];
          open-floating = true;
          default-column-width.proportion = 1.5 / 5.0;
          default-window-height.proportion = 1.5 / 5.0;
          default-floating-position = {
            relative-to = "bottom-right";
            x = 10;
            y = 10;
          };
        }
        # firefox developer floating and bottom-right
        {
          matches = [
            {
              app-id = "^firefox$";
              title = "^$";
            }
          ];
          open-floating = true;
          default-column-width.proportion = 2.0 / 5.0;
          default-window-height.proportion = 2.5 / 5.0;
          default-floating-position = {
            relative-to = "bottom-right";
            x = 10;
            y = 10;
          };
        }
        # max size
        {
          matches = [
            { app-id = "^firefox$"; }
          ];
          excludes = [
            { title = "Picture-in-Picture"; }
          ];
          default-column-width.proportion = 1.0;
        }
        # half size
        {
          matches = [
            { app-id = "ghostty$"; }
          ];
          default-column-width.proportion = 1.0 / 3.0;
        }
      ];
    };
  };
}
