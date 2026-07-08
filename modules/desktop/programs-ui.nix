{ pkgs, ... }:
let
  sddm-astronaut =
    (pkgs.sddm-astronaut.override {
      embeddedTheme = "post-apocalyptic_hacker"; # or any other theme
      themeConfig = {
        # Customize colors and settings
        HeaderTextColor = "#d5c4a1";
        Background = "Backgrounds/custom-background.mp4";
        # ... other theme configuration options
      };
    }).overrideAttrs
      (oldAttrs: {
        # Optional: Inject custom background image
        installPhase = oldAttrs.installPhase + ''
          chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/
          cp ${../../home/images/wallpapers/white-tree-sunset.mp4} \
            $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/custom-background.mp4
        '';
      });
in
{

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.sddm;
    extraPackages = with pkgs; [
      kdePackages.qtmultimedia # Required for video backgrounds/audio
    ];
    theme = "sddm-astronaut-theme";
  };
  programs.gpu-screen-recorder.enable = true;

  environment.systemPackages = with pkgs; [
    imagemagick
    mpv
    showmethekey
    hyprpolkitagent
    grim
    xwayland-satellite
    sddm-astronaut
    # qt6Packages.qt6ct
    # niri
  ];

  programs.niri = {
    enable = true;
    # useNautilus = false;
  };

}
