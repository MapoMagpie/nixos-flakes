{ pkgs, config, ... }:
{
  imports = [
    ./zsh.nix
  ];

  home.file.".config/xdg-desktop-portal-termfilechooser/config".text = ''
    [filechooser]
    cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
    default_dir=$HOME
    env=TERMCMD=kitty --app-id="kitty.yazi.filechooser"
  '';
  home.file.".config/xdg-desktop-portal/portals.conf".text = ''
    [preferred]
    org.freedesktop.impl.portal.FileChooser=termfilechooser
  '';

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "0xProto Nerd Font Mono";
      size = 16;
    };
    shellIntegration = {
      enableZshIntegration = true;
      mode = "no-cursor";
    };
    settings = {
      cursor = "#f0c30f";
      cursor_text_color = "#f0c30f";
      cursor_shape = "underline";
      # cursor_trail = 1;
      # cursor_trail_decay = "0.3 0.6";
      background_opacity = 0.77;
      symbol_map = "U+3000-U+30ff,U+4e00-U+9fff LXGW WenKai Mono Medium";
      allow_remote_control = true;
    };
    extraConfig = ''
      include ${config.home.homeDirectory}/nixos/home/term/kitty_theme.conf
    '';
  };

}
