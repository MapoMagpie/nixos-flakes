{
  pkgs,
  host,
  rimedm,
  senime,
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
    # GLib/GIO resolves `Terminal=true` .desktop apps by searching a hardcoded
    # list of program names (xdg-terminal-exec, kgx, gnome-terminal, ... xterm)
    # on PATH — it never reads $TERMINAL. kitty is not on that list, so GIO
    # launchers (shojibar's AstalApps launcher, GTK open-with, ...) fail with
    # "Unable to find terminal required for application". Provide a PATH
    # executable named `xterm` that just execs kitty, satisfying GLib's lookup
    # (GLib invokes it as `xterm -e <app>...`, which lands on `kitty -e <app>`).
    (writeShellScriptBin "xterm" ''
      exec kitty "$@"
    '')
    rimedm.packages.${pkgs.stdenv.hostPlatform.system}.default
    senime.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
