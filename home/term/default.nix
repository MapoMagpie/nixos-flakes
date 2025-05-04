{ ... }:
{
  imports = [
    ./zsh.nix
  ];

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
      cursor_trail = 1;
      cursor_trail_decay = "0.3 0.6";
      background_opacity = 0.7;
      symbol_map = "U+3000-U+30ff,U+4e00-U+9fff LXGW WenKai Mono Medium";
    };
    extraConfig = ''
      include theme.conf
    '';
  };

}
