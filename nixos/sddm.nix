{ pkgs, host, ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      sddm-astronaut = super.sddm-astronaut.override {
        embeddedTheme = "pixel_sakura";
        themeConfig = {
          ScreenWidth = host.screen.w;
          ScreenHeight = host.screen.h;
        };
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
