{ pkgs, ... }:
{
  imports = [ ./steam.nix ];
  environment.systemPackages = [ pkgs.prismlauncher ];
}
