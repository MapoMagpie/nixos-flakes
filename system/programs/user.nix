{
  pkgs,
  host,
  rimedm,
  ...
}:
{
  users.users."${host.username}".packages = with pkgs; [
    zoxide
    nil
    nixfmt
    gitui
    yt-dlp
    kitty
    rimedm.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
