{
  pkgs,
  ...
}:
{

  programs.gpu-screen-recorder.enable = true;

  environment.systemPackages = with pkgs; [
    imagemagick
    mpv
    showmethekey
    hyprpolkitagent
    grim
    xwayland-satellite
    # qt6Packages.qt6ct
    # niri
  ];

  programs.niri = {
    enable = true;
    # useNautilus = false;
  };

  # systemd.packages = [ pkgs.niri ];
  # # Restarting the compositor kills the graphical session; same
  # # treatment as the display-manager modules.
  # systemd.user.services.niri = {
  #   restartIfChanged = false;
  #   # Defining the unit here generates a drop-in; without this it
  #   # would carry the NixOS default Environment="PATH=coreutils:…",
  #   # clobbering the PATH that niri-session imported into the user
  #   # manager and breaking spawn actions that rely on it.
  #   enableDefaultPath = false;
  # };

  # services.displayManager.sessionPackages = [
  #   pkgs.niri
  # ];
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  programs.qylock = {
    enable = true;
    # theme = "nier-automata"; # any directory name under themes/
    theme = "winter"; # any directory name under themes/
    # sddm.enable = true;             # installs theme + sets it active (default)
    # quickshell.enable = true;       # adds `qylock-lock` to PATH (default)

    # Optional per-theme tweaks (replaces the interactive prompts):
    # themeOptions = {
    #   terraria.backgroundMode = "time"; # time | random | static
    #   Genshin.backgroundMode = "time";
    #   clockwork.orbital = {
    #     themeMode = "dark";
    #     enableWindup = true;
    #   };
    #   osu.gameMode = "menu"; # menu | game
    # };
  };
}
