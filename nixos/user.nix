{
  pkgs,
  host,
  lib,
  ...
}:
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
    ]
    ++ (
      if host.hostname == "slavenixostwo" then
        [
          "qbittorrent"
          "qui"
        ]
      else
        [ ]
    );
    openssh.authorizedKeys.keys = host.openssh.authorizedKeys.keys;
    maid =
      let
        args = {
          inherit host;
          inherit pkgs;
        };
        maid = import ./maid/default.nix args;
        ui = if host.hostname == "slavenixostwo" then { packages = [ ]; } else import ./maid/ui.nix args;
        programs = {
          packages = maid.packages ++ ui.packages;
        };
      in
      lib.recursiveUpdate (lib.recursiveUpdate maid ui) programs;
  };

}
