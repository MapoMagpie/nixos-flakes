{
  pkgs,
  host,
  externalFonts,
  ...
}:
{

  # echo -n "serif charset 骨门关复尖 : "; fc-match "serif:charset=9aa8"
  environment.systemPackages = [ pkgs.fontpreview ];
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Roboto Slab"
          "LXGW WenKai"
        ];
        sansSerif = [
          "Roboto Flex"
          "LXGW WenKai Screen"
        ];
        emoji = [ "Noto Color Emoji" ];
        monospace = [
          "0xProto Nerd Font Mono"
          "LXGW WenKai Mono"
        ];
      };
    };
    packages =
      with pkgs;
      [
        roboto-slab # bold serif
        roboto-flex # sans serif
        roboto-mono
        roboto-serif
        nerd-fonts._0xproto
        noto-fonts-color-emoji
        lxgw-wenkai
        lxgw-neoxihei
        lxgw-wenkai-tc
        lxgw-fusionkai
        lxgw-wenkai-screen
        sarasa-gothic
        dejavu_fonts
        unifont
        externalFonts.default
      ]
      ++ (
        if host.enable_ui then
          [
            externalFonts.default
          ]
        else
          [ ]
      )

    ;
    enableDefaultPackages = false;
    fontDir.enable = true;
  };

}
