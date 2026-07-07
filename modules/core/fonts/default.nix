{ pkgs, ... }:
{

  fonts = {
    packages = with pkgs; [
      nerd-fonts._0xproto
      nerd-fonts._3270
      noto-fonts-color-emoji
      lxgw-wenkai
      lxgw-neoxihei
      lxgw-wenkai-tc
      lxgw-fusionkai
      lxgw-wenkai-screen
      sarasa-gothic
      (pkgs.stdenv.mkDerivation {
        name = "local_fonts";
        src = ./fonts;
        installPhase = ''
          mkdir -p $out/share/fonts/truetype
          cp $src/*.{ttf,otf} $out/share/fonts/truetype/
        '';
      })
    ];
    enableDefaultPackages = true;
    fontDir.enable = true;
  };

}
