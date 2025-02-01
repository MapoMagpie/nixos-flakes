{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = false;
    xwayland.enable = false;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
    settings = {
      monitor = ", prefered, auto, 1";
      general = {
        gaps_in = 5;
        gaps_out = "10, 20, 10, 20";
        border_size = 2;
        "col.active_border" = "rgb(f0d32f)";
        "col.inactive_border" = "rgb(a0a30f)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "master";
      };
      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };
      # animations = {
      #     enabled = true;
      #     bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      #     animation = [
      #       "windows, 1, 7, myBezier"
      #       "windowsOut, 1, 7, default, popin 80%"
      #       "border, 1, 10, default"
      #       "borderangle, 1, 8, default"
      #       "fade, 1, 7, default"
      #       "workspaces, 1, 6, default"
      #     ];
      # };
      master = {
        allow_small_split = false;
        special_scale_factor = 1;
        mfact = 0.6;
        new_status = "slave";
        new_on_top = false;
        new_on_active = "none";
        orientation = "left";
        inherit_fullscreen = true;
        always_center_master = false;
        smart_resizing = true;
        drop_at_cursor = false;
      };
      misc = {
        # Set to 0 or 1 to disable the anime mascot wallpapers
        force_default_wallpaper = -1;
        # If true disables the random hyprland logo / anime girl background. :(
        disable_hyprland_logo = false;
      };
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        # -1.0 - 1.0, 0 means no modification.
        sensitivity = 0;
        touchpad = {
          disable_while_typing = true;
          natural_scroll = false;
        };
        touchdevice = {
          enabled = false;
        };
        repeat_rate = 70;
        repeat_delay = 400;
      };
      gestures = {
        workspace_swipe = false;
      };
      #device = {
      #name = "epic-mouse-v1";
      #sensitivity = -0.5;
      #};
      # Sets "Windows" key as main modifier
      "$mod" = "SUPER";
      bind = [
        "$mod, Return, exec, foot"
        "$mod, Space, exec, fuzzel --terminal=foot"
        "$mod, E, exec, lf"
        "$mod, Q, killactive"
        "$mod, M, exit,"
        "$mod, F, togglefloating"
        # $mod, P, pseudo, # dwindle
        # $mod, J, togglesplit, # dwindle
        # screenshot
        "$mod, S, exec, slurp > /tmp/geometry && notify-send \"$(cat /tmp/geometry)\""
        "$mod SHIFT, S, exec, sleep 3 && grim -g \"$(cat /tmp/geometry)\" /home/mapo-magpie/Pictures/screenshots/grim_$(date +\"%Y%m%d_%H%M%S\").png && notify-send \"Screenshot Done\""
        # record
        "$mod SHIFT, E, exec, notify-send \"wf-recorder started\" && wf-recorder -g \"$(cat /tmp/geometry)\" -r 30 -f /home/mapo-magpie/Videos/rec_$(date +\"%Y%m%d_%H%M%S\").mp4 && notify-send \"wf-recorder done\""
        "$mod ALT, E, exec, killall wf-recorder"
        # Move focus with mainMod + arrow keys
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        # swaps the active window with another window in the given direction
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"
        # cycle to the next orientation for the current workspace
        "$mod, R, layoutmsg, orientationnext"
        "$mod SHIFT, R, layoutmsg, orientationprev"
        # Switch workspaces with mainMod + [0-9]
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"
        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
        # Scroll through existing workspaces with mainMod + scroll
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
      ];
      binde = [
        # resizes the active window
        "$mod ALT, H, resizeactive, -30 0"
        "$mod ALT, L, resizeactive, 30 0"
        "$mod ALT, J, resizeactive, 0 30"
        "$mod ALT, K, resizeactive, 0 -30"
        # moves the active window (float)
        "$mod SHIFT ALT, H, moveactive, -30 0"
        "$mod SHIFT ALT, L, moveactive, 30 0"
        "$mod SHIFT ALT, J, moveactive, 0 30"
        "$mod SHIFT ALT, K, moveactive, 0 -30"
      ];
      bindm = [
        # Move/resize windows with mainMod + LMB/RMB and dragging
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      windowrulev2 = [
        # rules
        # You'll probably like this.
        "suppressevent maximize, class:.*"
        # dragon-drop
        "move 100%-w-10 50,class:(dragon-drop)"
        "opacity 0.8 0.3,class:(dragon-drop)"
        "rounding 0,class:(dragon-drop)"
        "noborder,class:(dragon-drop)"
        # mpv
        "float,class:(mpv)"
        "size 850 500,class:(mpv)"
        "move 1650 900,class:(mpv)"
        "opaque,class:(mpv)"
        # firefox picture in picture
        "float,title:^(Firefox)$,class:^(firefox)$"
        "size 800 450,title:^(Firefox)$,class:^(firefox)$"
        "move 1730 960,title:^(Firefox)$,class:^(firefox)$"
        "float,title:([pP]icture.*[iI]n.*[pP]icture)"
        "size 800 450,title:([pP]icture.*[iI]n.*[pP]icture)"
        "move 1730 960,title:([pP]icture.*[iI]n.*[pP]icture)"
        # firefox
        "workspace 1,class:(firefox)"
        "opaque,class:(firefox)"
        # telegram
        "workspace 4,class:(org.telegram.desktop)"
        # steam
        "workspace 4,class:(steam)"
        "stayfocused, title:^()$,class:^(steam)$"
        "minsize 1 1, title:^()$,class:^(steam)$"
        # tina roam
        "workspace 2,title:(Tina Roam)"
        "float,title:(Tina Roam)"
        # sxiv do not float
        "tile,class:(Sxiv)"
        "opaque,class:(Sxiv)"
        # neovide do not float
        # "nomaximizerequest,class:(neovide)"
        # "nofullscreenrequest,class:(neovide)"
        # "suppressevent maximize,class:(neovide)"
        # "tile,class:(neovide)"
        # rdesktop float center
        # "float,class:(rdesktop)"
        # "float,class:(wlfreerdp)"
        # "workspace 5,class:(wlfreerdp)"
      ];
      "exec-once" = [
        "waybar"
        # exec-once = mako -c ~/.config/mako/mako.conf
        # exec-once = fcitx5 -rd -u wayland
        "fcitx5 -rd"
      ];
    };
  };
}
