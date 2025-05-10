{ pkgs, ... }:
{
  home.packages = [ pkgs.fuzzel ];
  home.file.".config/fuzzel/fuzzel.ini".text =
    let
      base = builtins.readFile ./base.ini;
      colors = builtins.readFile ./colors.ini;
    in
    base + colors;
}
