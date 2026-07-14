{
  pkgs,
  host,
  externalFonts,
  ...
}:
{

  fonts = {
    packages =
      with pkgs;
      [
        nerd-fonts._0xproto
        nerd-fonts._3270
        noto-fonts-color-emoji
        lxgw-wenkai
        lxgw-neoxihei
        lxgw-wenkai-tc
        lxgw-fusionkai
        lxgw-wenkai-screen
        sarasa-gothic
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
    enableDefaultPackages = true;
    fontDir.enable = true;
  };

}
