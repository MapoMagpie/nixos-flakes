{ host, config, ... }:
{
  services.playerctld.enable = true;
  home.file.".config/waybar/style.css".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/ui/waybar.css";
  home.file.".config/waybar/waybar-ddc-module.sh".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/home/ui/waybar-ddc-module.sh";
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        "layer" = "top";
        "position" = "top";
        # "height" = 28;
        "width" = host.screen.w;
        "spacing" = 0;
        "margin-top" = 6;
        "modules-left" = [
          "clock"
          "niri/workspaces"
          "niri/window"
        ];
        "modules-right" = [
          "mpris"
          "network"
          "cpu"
          "memory"
          "disk"
          "pulseaudio"
          "custom/backlight"
          "tray"
        ];

        "clock" = {
          "format" = " {:%A, %m/%d, [%H:%M]}";
          "tooltip-format" = "<tt><small>{calendar}</small></tt>";
          "calendar" = {
            "mode" = "year";
            "mode-mon-col" = 3;
            "weeks-pos" = "right";
            "on-scroll" = 1;
            "on-click-right" = "mode";
            "format" = {
              "months" = "<span color='#ffead3'><b>{}</b></span>";
              "days" = "<span color='#ecc6d9'><b>{}</b></span>";
              "weeks" = "<span color='#99ffdd'><b>W{}</b></span>";
              "weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
              "today" = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          "actions" = {
            "on-click-right" = "mode";
            "on-click-forward" = "tz_up";
            "on-click-backward" = "tz_down";
            "on-scroll-up" = "shift_up";
            "on-scroll-down" = "shift_down";
          };
        };

        "mpris" = {
          "format" = "{player_icon} {dynamic}";
          "format-paused" = "{status_icon} <i>{dynamic}</i>";
          "player-icons" = {
            "default" = "▶";
            "mpv" = "🎵";
            "firefox" = "🎵";
          };
          "status-icons" = {
            "paused" = "⏸";
          };
          "dynamic-len" = 30;
          "dynamic-order" = [
            "title"
            # "artist"
            "album"
            # "position"
            "length"
          ];
          "dynamic-importance-order" = [
            # "title"
            # "artist"
            # "album"
            # "position"
            # "length"
          ];
        };

        "niri/workspaces" = {
          "format" = "{icon}";
          "format-icons" = {
            "1" = "NET:";
            "2" = "TERM:";
            "3" = "CODE:";
            "4" = "CHAT:";
            "5" = "REMO:";
            "default" = "TEMP:";
          };
          "current-only" = true;
        };

        "niri/window" = {
          "format" = " {title} ";
          "max-length" = host.screen.w * 0.3;
          "rewrite" = {
            "" = "-`♡´-";
          };
        };

        "hyprland/workspaces" = {
          "format" = "{icon}";
          "format-icons" = {
            "1" = "NET:";
            "2" = "TERM:";
            "3" = "CODE:";
            "4" = "CHAT:";
            "5" = "REMO:";
            "default" = "TEMP:";
          };
          "persistent-workspaces" = {
            "*" = 5;
          };
          "active-only" = false;
          "sort-by-number" = true;
        };

        "hyprland/window" = {
          "format" = "-`♡´-{}";
          "max-length" = 760;
          "rewrite" = {
            "-`♡´-(.+)" = "$1";
          };
        };
        "tray" = {
          "spacing" = 10;
        };
        "network" = {
          "interval" = 1;
          "format-wifi" = "[信]{bandwidthTotalBytes} ";
          "tooltip-format" = "{ifname} via {gwaddr} \n▲{bandwidthUpBytes}▼{bandwidthDownBytes}";
          "format-disconnected" = "孤";
        };
        # "backlight" = {
        #   "device" = "intel_backlight";
        #   "format" = "[光]{percent}";
        #   # "format-icons" = [
        #   #   ""
        #   #   ""
        #   # ];
        # };
        "cpu" = {
          "format" = "[算]{usage}% ";
          "tooltip" = false;
        };
        "memory" = {
          "format" = "[存]{used} ";
          "tooltip-format" = "used {used}G, total {total}G, {percentage}%";
        };
        "disk" = {
          "interval" = 30;
          "format" = "[贮]{specific_used:0.1f} ";
          "unit" = "GB";
          "path" = "/";
        };
        "pulseaudio" = {
          "format" = "[音]{volume} ";
          "format-muted" = "静";
          # "on-click" = "pavucontrol";
        };
        "custom/backlight" = {
          "format" = "[光]{percentage}";
          "exec-on-event" = true;
          "exec" = "${config.home.homeDirectory}/.config/waybar/waybar-ddc-module.sh";
          "return-type" = "json";
          "on-scroll-up" = ''echo "+" > /tmp/waybar-ddc-module-rx'';
          "on-scroll-down" = ''echo "-" > /tmp/waybar-ddc-module-rx'';
          "on-click" = ''echo "min" > /tmp/waybar-ddc-module-rx'';
          "on-click-right" = ''echo "max" > /tmp/waybar-ddc-module-rx'';
          "tooltip" = false;
        };
        # "custom/waybar-mpris" = {
        #   "return-type" = "json";
        #   "exec" = "waybar-mpris --position --autofocus --width 25 --order 'TITLE =SYMBOL =POSITION'";
        #   "on-click" = "waybar-mpris --send toggle";
        #   "on-click-right" = "waybar-mpris --send next";
        #   "on-scroll-up" = "waybar-mpris --send player-prev";
        #   "on-scroll-down" = "waybar-mpris --send player-next";
        #   "escape" = true;
        # }
      };
    };
  };
}
# style = (builtins.readFile ./waybar.css);
