{ host, ... }: {
  imports = [
    ./system.nix
    ./user.nix
  ]
  ++ (
    if host.enable_ui then
      [
        ./system-ui.nix
        ./user-ui.nix
        ./fcitx.nix
      ]
    else
      [ ]
  )
  ++ (if host.enable_game then [ ./game ] else [ ]);
}
