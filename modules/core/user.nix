{
  pkgs,
  host,
  ...
}:
let
  commonUserPkgs = with pkgs; [
    zoxide
    nil
    nixfmt
    gitui
    yt-dlp
    kitty
  ];
in
{
  users.users."${host.username}" = {
    isNormalUser = true;
    description = host.userDesc;
    initialPassword = host.userInitPass;
    shell = pkgs.bash;
    extraGroups = [
      "networkmanager"
      "wheel"
      "i2c"
      "libvirtd"
    ];
    openssh.authorizedKeys.keys = host.openssh.authorizedKeys.keys;
    packages = commonUserPkgs;
  };
}
