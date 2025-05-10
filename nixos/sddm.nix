{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      sddm-astronaut = super.sddm-astronaut.override {
        embeddedTheme = "hyprland_kath";
      };
    })
  ];
  environment.systemPackages = [ pkgs.sddm-astronaut ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.kdePackages.sddm;
    extraPackages = [ pkgs.sddm-astronaut ];
  };
}
