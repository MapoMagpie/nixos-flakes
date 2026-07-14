{
  host,
  lib,
  pkgs,
  ...
}@input:
let
  homeDir = "/home/${host.username}";
  currDir = "${homeDir}/nixos/home";
  mkLinkCommands =
    links:
    lib.concatMapStringsSep "\n" (
      { target, source }:
      "mkdir -p $(dirname ${homeDir}/${target}) && ln -sfn ${source} ${homeDir}/${target}"
    ) links;
  base = import ./base.nix (
    {
      inherit homeDir currDir mkLinkCommands;
    }
    ++ input
  );
  activationScript = pkgs.writeShellScriptBin "dotfiles-activate" ''
    set -e
    ${base}
  '';
in
{
  programs.dconf.enable = true;

  systemd.user.services.dotfiles-activation = {
    wantedBy = [ "default.target" ];
    before = [ "graphical-session-pre.target" ];
    after = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${activationScript}/bin/dotfiles-activate";
    };
    restartTriggers = [ activationScript ];
    restartIfChanged = true;
  };
}
