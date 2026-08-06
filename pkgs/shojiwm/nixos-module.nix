{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.shojiwm;
  defaultXwayland = pkgs.xwayland or (pkgs.xorg.xwayland or null);
  defaultSatellite = pkgs.xwayland-satellite or null;
  gtkPortal = pkgs.xdg-desktop-portal-gtk or null;
  initConfigUsers = cfg.initConfig.users;

  shojiPackage =
    if cfg.package ? override then
      cfg.package.override {
        xwayland = defaultXwayland;
        xwaylandSatellite = if cfg.xwaylandSatellite.enable then cfg.xwaylandSatellite.package else null;
      }
    else
      cfg.package;

  # Session entrypoint, modeled after upstream niri-session: when a systemd
  # user manager is present the session is started as `shojiwm.service`, whose
  # BindsTo=graphical-session.target pulls the target in (RefuseManualStart=yes
  # on systemd >= 254 forbids starting it manually). Without systemd we fall
  # back to exec'ing the compositor directly.
  sessionScript = pkgs.writeShellScript "shojiwm-session" ''
    if [ -n "$SHELL" ] &&
       grep -q "$SHELL" /etc/shells &&
       ! (echo "$SHELL" | grep -q "false") &&
       ! (echo "$SHELL" | grep -q "nologin"); then
      if [ "$1" != '-l' ]; then
        exec bash -c "exec -l '$SHELL' -c 'exec $0 -l $*'"
      else
        shift
      fi
    fi

    if hash systemctl >/dev/null 2>&1; then
      # Make sure there's no already running session.
      if systemctl --user -q is-active shojiwm.service; then
        echo 'A ShojiWM session is already running.'
        exit 1
      fi

      # Reset failed state of all user units.
      systemctl --user reset-failed 2>/dev/null || true

      # Import the login manager environment (PATH, WAYLAND_DISPLAY, ...) into
      # the user systemd manager, so spawned commands and dbus-activated
      # services see it.
      systemctl --user import-environment

      if hash dbus-update-activation-environment 2>/dev/null; then
        dbus-update-activation-environment --all
      fi

      # Start the compositor and wait for it to terminate.
      systemctl --user --wait start shojiwm.service

      # Force stop of graphical-session.target.
      systemctl --user start --job-mode=replace-irreversibly shojiwm-shutdown.target

      # Unset session environment so a re-login starts clean.
      systemctl --user unset-environment WAYLAND_DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP
    else
      echo "No systemd user manager detected, exec'ing ShojiWM directly."
      exec ${shojiPackage}/bin/shoji_wm --tty
    fi
  '';

  # Replacement wayland-session entry so SDDM starts shojiwm-session instead of
  # the upstream `shoji_wm --tty` directly.
  sessionPackage =
    (pkgs.writeTextFile {
      name = "shojiwm-wayland-session";
      destination = "/share/wayland-sessions/shojiwm.desktop";
      text = ''
        [Desktop Entry]
        Name=ShojiWM
        Comment=Start the ShojiWM Wayland compositor
        Exec=${sessionScript}
        Type=Application
        DesktopNames=ShojiWM
      '';
    })
    // {
      providedSessions = [ "shojiwm" ];
    };
in
{
  options.programs.shojiwm = {
    enable = lib.mkEnableOption "ShojiWM";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.shojiwm;
      defaultText = lib.literalExpression "pkgs.shojiwm";
      description = "ShojiWM package to install.";
    };

    portal.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable xdg-desktop-portal-shojiwm for screen capture.";
    };

    portal.gtkFallback = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install xdg-desktop-portal-gtk as the fallback portal backend.";
    };

    initConfig.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to initialize ShojiWM TypeScript config for selected users
        during system activation. Existing src/index.tsx files are kept, while
        the shoji_wm package symlink is refreshed on every activation.
      '';
    };

    initConfig.users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "bea4dev" ];
      description = "Users whose ~/.config/shojiwm directory should be initialized.";
    };

    xwaylandSatellite.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to configure ShojiWM to use xwayland-satellite.";
    };

    xwaylandSatellite.package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = defaultSatellite;
      defaultText = lib.literalExpression "pkgs.xwayland-satellite or null";
      description = ''
        xwayland-satellite package used by ShojiWM. Override this with a forked
        package, for example a Unity compatibility branch, when needed.
      '';
    };

    session.systemd.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Manage the ShojiWM session through the user systemd manager, following
        the niri pattern: the session entrypoint starts `shojiwm.service`, whose
        `BindsTo=graphical-session.target` activates `graphical-session.target`
        (which `RefuseManualStart=yes` on systemd >= 254 otherwise forbids
        starting manually). On exit, `shojiwm-shutdown.target` tears the
        graphical session down. Disable to keep the upstream behaviour of
        exec'ing `shoji_wm --tty` directly, leaving `graphical-session.target`
        inactive.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.xwaylandSatellite.enable || cfg.xwaylandSatellite.package != null;
        message = ''
          programs.shojiwm.xwaylandSatellite.enable is true, but pkgs.xwayland-satellite
          is not available. Set programs.shojiwm.xwaylandSatellite.package explicitly,
          or disable xwaylandSatellite.
        '';
      }
      {
        assertion = !cfg.portal.enable || !cfg.portal.gtkFallback || gtkPortal != null;
        message = ''
          programs.shojiwm.portal.gtkFallback is true, but xdg-desktop-portal-gtk
          is not available in this nixpkgs. Disable gtkFallback or provide a newer nixpkgs.
        '';
      }
      {
        assertion = !cfg.initConfig.enable || initConfigUsers != [ ];
        message = ''
          programs.shojiwm.initConfig.enable is true, but initConfig.users is empty.
          Set programs.shojiwm.initConfig.users to the user accounts that should
          receive ~/.config/shojiwm.
        '';
      }
      {
        assertion =
          !cfg.initConfig.enable || lib.all (user: builtins.hasAttr user config.users.users) initConfigUsers;
        message = ''
          programs.shojiwm.initConfig.users contains a user that is not declared
          in users.users. Declare the user in users.users or remove it from the
          initConfig.users list.
        '';
      }
    ];

    environment.systemPackages = [
      shojiPackage
    ]
    ++ lib.optional (defaultXwayland != null) defaultXwayland
    ++ lib.optional (
      cfg.xwaylandSatellite.enable && cfg.xwaylandSatellite.package != null
    ) cfg.xwaylandSatellite.package
    ++ lib.optional (cfg.portal.enable && cfg.portal.gtkFallback && gtkPortal != null) gtkPortal;

    services.displayManager.sessionPackages =
      if cfg.session.systemd.enable then [ sessionPackage ] else [ shojiPackage ];

    # When the session runs as `shojiwm.service`, `BindsTo=` pulls in
    # `graphical-session.target` (niri-style), satisfying the
    # `Requisite=graphical-session.target` added by xdg-desktop-portal >= 1.22.
    systemd.user.services.shojiwm = lib.mkIf cfg.session.systemd.enable {
      description = "ShojiWM Wayland compositor";
      bindsTo = [ "graphical-session.target" ];
      before = [
        "graphical-session.target"
        "xdg-desktop-autostart.target"
      ];
      wants = [
        "graphical-session-pre.target"
        "xdg-desktop-autostart.target"
      ];
      after = [ "graphical-session-pre.target" ];
      restartIfChanged = false;
      # Don't clobber the login PATH imported by shojiwm-session; shoji_wm
      # spawns user commands (fcitx5, swayidle, ags, ...) from its config.
      enableDefaultPath = false;
      serviceConfig = {
        Type = "simple";
        ExecStart = "${shojiPackage}/bin/shoji_wm --tty";
        Slice = "session.slice";
      };
    };

    systemd.user.targets.shojiwm-shutdown = lib.mkIf cfg.session.systemd.enable {
      description = "Shutdown running ShojiWM session";
      conflicts = [
        "graphical-session.target"
        "graphical-session-pre.target"
      ];
      after = [
        "graphical-session.target"
        "graphical-session-pre.target"
      ];
      unitConfig = {
        DefaultDependencies = "no";
        StopWhenUnneeded = "true";
      };
    };

    hardware.graphics.enable = true;

    system.activationScripts.shojiwm-init-config = lib.mkIf cfg.initConfig.enable (
      lib.stringAfter [ "users" ] (
        lib.concatMapStringsSep "\n" (
          user:
          let
            userConfig = config.users.users.${user};
            home = userConfig.home or "/home/${user}";
            group = userConfig.group or "users";
            quotedUser = lib.escapeShellArg user;
            quotedGroup = lib.escapeShellArg group;
            quotedHome = lib.escapeShellArg home;
            quotedConfigHome = lib.escapeShellArg "${home}/.config";
          in
          ''
            echo "initializing ShojiWM config for ${user}"
            install -d -m 0755 -o ${quotedUser} -g ${quotedGroup} ${quotedHome}
            ${pkgs.util-linux}/bin/runuser -u ${quotedUser} -- \
              env HOME=${quotedHome} XDG_CONFIG_HOME=${quotedConfigHome} \
              ${shojiPackage}/bin/shojiwm-init-config
          ''
        ) initConfigUsers
      )
    );

    xdg.portal = lib.mkIf cfg.portal.enable {
      enable = true;
      extraPortals = [
        shojiPackage
      ]
      ++ lib.optional (cfg.portal.gtkFallback && gtkPortal != null) gtkPortal;
      config.ShojiWM = {
        "org.freedesktop.impl.portal.ScreenCast" = [ "shojiwm" ];
      }
      // lib.optionalAttrs cfg.portal.gtkFallback {
        default = [ "gtk" ];
      };
    };

    systemd.user.services.xdg-desktop-portal-shojiwm = lib.mkIf cfg.portal.enable {
      description = "Portal service (ShojiWM implementation)";
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "dbus";
        BusName = "org.freedesktop.impl.portal.desktop.shojiwm";
        ExecStart = "${shojiPackage}/bin/xdg-desktop-portal-shojiwm";
        Restart = "always";
        RestartSec = "500ms";
        TimeoutStopSec = "10";
      };
    };
  };
}
