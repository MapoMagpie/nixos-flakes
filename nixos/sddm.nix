{ pkgs, ... }:
let
  sddm-astronaut = pkgs.callPackage pkgs.sddm-astronaut {
    embeddedTheme = "hyprland_kath";
  };
in
{
  environment.systemPackages = [
    sddm-astronaut
  ];

  # nixpkgs.overlays = [
  #   (self: super: {
  #     sddm-astronaut = super.sddm-astronaut.override {
  #       embeddedTheme = "hyprland_kath";
  #     };
  #   })
  # ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.kdePackages.sddm;
    extraPackages = [ sddm-astronaut ];
  };
}
