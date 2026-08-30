{ pkgs, ... }:
{

  # 验证： fc-match "serif:lang=zh" 等命令检查每个族的本地化首选
  environment.systemPackages = [ pkgs.fontforge ];
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Roboto Slab"
          "Nono Serif"
          "LXGW WenKai"
        ];
        sansSerif = [
          "Roboto Flex"
          "Nono Sans"
          "LXGW WenKai Screen"
          "Noto Sans Symbols"
          "Noto Sans Symbols 2"
        ];
        monospace = [
          "0xProto Nerd Font Mono"
          "Noto Sans Symbols"
          "Noto Sans Symbols 2"
          "Comic Mono"
          "LXGW WenKai Mono"
        ];
        emoji = [
          "Noto Color Emoji"
        ];
      };
    };
    packages = with pkgs; [
      roboto-slab # bold serif
      roboto-flex # sans serif
      roboto-mono
      roboto-serif
      nerd-fonts._0xproto
      lxgw-wenkai
      lxgw-neoxihei
      lxgw-wenkai-tc
      lxgw-fusionkai
      lxgw-wenkai-screen
      noto-fonts
      noto-fonts-color-emoji
      comic-mono # Legible monospace font that looks like Comic Sans.
    ];
    enableDefaultPackages = false;
    fontDir.enable = true;
  };
}
