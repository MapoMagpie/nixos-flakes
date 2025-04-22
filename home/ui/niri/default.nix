{
  pkgs,
  config,
  ...
}:
{

  # imports = [ niri.homeModules.config ];
  home.packages = [ pkgs.xwayland-satellite ];

  programs.niri.settings = {
    prefer-no-csd = true;
    workspaces = {
      "01_NETW" = {
        name = "NETW";
      };
      "02_CODE" = {
        name = "CODE";
      };
      "03_CHAT" = {
        name = "CHAT";
      };
      "04_GAME" = {
        name = "GAME";
      };
    };
    environment = {
      QT_QPA_PLATFORM = "wayland";
      EDITOR = "hx";
      TERMINAL = "kitty";
      DISPLAY = ":0";
    };
    spawn-at-startup = [
      { command = [ "ironbar" ]; }
      {
        command = [
          "fcitx5"
          "-d"
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
      # {
      #   command = [
      #     "swww"
      #     "img"
      #     "${config.xdg.configHome}/nixos/home/images/wallpapers/4.png"
      #     "--transition-type"
      #     "center"
      #   ];
      # }
      { command = [ "xwayland-satellite" ]; }
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
        left = 3;
        right = 3;
        top = 0;
        bottom = 3;
      };
    };
    binds =
      with config.lib.niri.actions;
      let
        sh = spawn "sh" "-c";
      in
      {
        # "Mod+Q".action = do-screen-transition;
        "Mod+Space" = {
          action = spawn "fuzzel";
          hotkey-overlay.title = "Open Launcher";
        };
        "Mod+Return" = {
          action = spawn "kitty";
          hotkey-overlay.title = "Open Terminal";
        };
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
        "Mod+1".action = focus-workspace "NETW";
        "Mod+2".action = focus-workspace "CODE";
        "Mod+3".action = focus-workspace "CHAT";
        "Mod+4".action = focus-workspace "GAME";
        "Mod+5".action = focus-workspace "TEMP";
        "Mod+Shift+1".action.move-window-to-workspace = "NETW";
        "Mod+Shift+2".action.move-window-to-workspace = "CODE";
        "Mod+Shift+3".action.move-window-to-workspace = "CHAT";
        "Mod+Shift+4".action.move-window-to-workspace = "GAME";
        "Mod+Shift+5".action.move-window-to-workspace = "TEMP";
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
        "Mod+V" = {
          action = sh "cliphist list | fuzzel -d | cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy";
          hotkey-overlay.title = "Show Clip History";
        };
        "Mod+W" = {
          action = sh "niri msg windows | ${config.home.homeDirectory}/nixos/home/misc/scripts/merge_window_info.sh | fuzzel -d | cut -d '/' -f1 | xargs -I {} niri msg action focus-window --id {}";
          hotkey-overlay.title = "Show All Windows";
        };
        "Mod+S" = {
          action = sh ''slurp > /tmp/geometry && notify-send "$(cat /tmp/geometry)"'';
          hotkey-overlay.title = "Slurp Geometry";
        };
        "Mod+Shift+S" = {
          action = sh ''sleep 3 && grim -g "$(cat /tmp/geometry)" ${config.home.homeDirectory}/Pictures/screenshots/grim_$(date +"%Y%m%d_%H%M%S").png && notify-send "Screenshot Done"'';
          hotkey-overlay.title = "Screenshot After 3 Second";
        };
        "Mod+Ctrl+S" = {
          action = sh ''cat /tmp/geometry | sd 'x' ',' | xargs -I{} swayimg -a pinimg -p {} -w {} '${config.home.homeDirectory}/Pictures/screenshots/'$(ls -t ${config.home.homeDirectory}/Pictures/screenshots | head -n 1)'';
          hotkey-overlay.title = "Pin the last screenshot";
        };
        "Mod+Shift+E" = {
          action = sh ''notify-send "wf-recorder started" && wf-recorder --audio -g "$(cat /tmp/geometry)" -r 60 -f ${config.home.homeDirectory}/Videos/screenshots/rec_$(date +"%Y%m%d_%H%M%S").mp4 && notify-send "wf-recorder done"'';
          hotkey-overlay.title = "Record Screen";
        };
        "Mod+Alt+E" = {
          action = sh ''killall -INT wf-recorder'';
          hotkey-overlay.title = "Stop Record Screen";
        };
      };
    window-rules = [
      # no background of border
      {
        matches = [
          { app-id = "kitty"; }
          { app-id = "^swayimg$"; }
          { app-id = "^showmethekey-gtk$"; }
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
      # showmethekey
      {
        matches = [
          { app-id = "^showmethekey-gtk$"; }
        ];
        open-floating = true;
        open-focused = false;
        default-column-width.proportion = 400.0 / 2560.0;
        default-window-height.proportion = 80.0 / 1440.0;
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
      # just floating
      {
        matches = [
          { app-id = "pinimg"; }
        ];
        open-floating = true;
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
          { app-id = "Minecraft"; }
          { app-id = "^org.telegram.desktop$"; }
        ];
        excludes = [
          { title = "Picture-in-Picture"; }
        ];
        default-column-width.proportion = 1.0;
      }
      # half size
      {
        matches = [
          { app-id = "kitty$"; }
        ];
        default-column-width.proportion = 1.0 / 2.0;
      }
      # fullscreen
      {
        matches = [
          { app-id = "^steam_app_[0-9]+"; }
        ];
        open-fullscreen = true;
      }
      # NETW
      {
        matches = [
          { app-id = "^firefox$"; }
          { app-id = "^chromium-browser$"; }
        ];
        open-on-workspace = "NETW";
      }
      # CODE
      {
        matches = [
          { app-id = "kitty$"; }
        ];
        open-on-workspace = "CODE";
      }
      # CHAT
      {
        matches = [
          { app-id = "^org.telegram.desktop$"; }
        ];
        open-on-workspace = "CHAT";
      }
      # GAME
      {
        matches = [
          { app-id = "^steam_app.*$"; }
          { app-id = "^steam$"; }
          { app-id = "PrismLauncher$"; }
          { app-id = "Minecraft"; }
        ];
        open-on-workspace = "GAME";
      }
      # TEMP_
      # {
      #   matches = [
      #     { app-id = "^steam_app.*$"; }
      #   ];
      #   open-on-workspace = "TEMP";
      # }
    ];
  };
}
