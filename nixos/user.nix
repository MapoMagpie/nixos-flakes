{ pkgs, host, ... }:
{
  users.users."${host.username}" = {
    isNormalUser = true;
    description = host.userDesc;
    initialPassword = host.userInitPass;
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "i2c"
      "libvirtd"
    ];
    openssh.authorizedKeys.keys = host.openssh.authorizedKeys.keys;
    maid = {
      file.home.".zshrc".text = ''
        eval "$(${pkgs.starship}/bin/starship init zsh)"
        eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
      '';
      file.xdg_config = {
        "mozilla/firefox/profiles.ini".source = ../home/firefox/profiles.ini;
        "mozilla/firefox/mapomagpie/user.js".source = ../home/firefox/user.js;
        "mozilla/firefox/mapomagpie/chrome".source = "{{home}}/nixos/external/firefox-compact-ui";

        "git/config".text = ''
          [user]
          	name = "${host.git.userName}"
          	email = "${host.git.userEmail}"
        '';

        "niri/config.kdl".source = "{{home}}/nixos/home/niri/config.kdl";

        "fuzzel/fuzzel.ini".text =
          let
            base = builtins.readFile ../home/fuzzel/base.ini;
            colors = builtins.readFile ../home/fuzzel/colors.ini;
          in
          base + colors;

        "quickshell".source = "{{home}}/nixos/home/quickshell";

        "matugen".source = "{{home}}/nixos/home/matugen";

        "yazi".source = "{{home}}/nixos/home/yazi";
        "kitty".source = "{{home}}/nixos/home/kitty";
        "starship.toml".source = "{{home}}/nixos/home/starship/starship.toml";

        "xdg-desktop-portal-termfilechooser/config".text = ''
          [filechooser]
          cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
          default_dir=$HOME
          env=TERMCMD=kitty --app-id="kitty.yazi.filechooser"
        '';

        "xdg-desktop-portal/portals.conf".text = ''
          [preferred]
          org.freedesktop.impl.portal.FileChooser=termfilechooser
        '';

        "helix".source = "{{home}}/nixos/home/helix";
        "swayimg/config".source = "{{home}}/nixos/home/swayimg/swayimg_config.ini";
        "swaylock/config".source = "{{home}}/nixos/home/swaylock/config";
      };

      file.xdg_data = {
        "fcitx5/rime".source = "{{home}}/nixos/external/rime";
      };

      packages =
        with pkgs;
        [
          mpvpaper
          sway-audio-idle-inhibit

          bibata-cursors
          zoxide
          kitty
          starship
          cliphist
          fuzzel
          quickshell
          matugen

          nixd
          nixfmt

          firefox
          swaylock
          swayidle
          gitui
          dragon-drop
          swayimg
          wf-recorder
          freerdp
          slurp
          yt-dlp
        ]
        ++ (
          if host.hostname == "maponixos" then
            [
              tsukimi
              zed-editor
              gimp3
              # kdePackages.kdenlive
              telegram-desktop
              chromium
            ]
          else
            [ ]
        );
      dconf.settings = {
        "/org/gnome/desktop/interface/color-scheme" = "prefer-dark";
        "/org/gnome/desktop/interface/cursor-theme" = "Bibata-Original-Amber";
      };
    };
  };

}
