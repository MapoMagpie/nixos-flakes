{ ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      github-copilot-cli = super.callPackage ./github-copilot-cli/package.nix { };
      flyline = super.callPackage ./flyline/package.nix { };
      helix = super.callPackage ./helix/package.nix { };
      astalPackages = builtins.removeAttrs (super.callPackage ./astal/package.nix { }) [
        "override"
        "overrideDerivation"
      ];
      ags = super.callPackage ./ags/package.nix {
        inherit (self.astalPackages) astal3 astal4;
        astal-io = self.astalPackages.io;
        extraPackages = builtins.attrValues self.astalPackages ++ [ super.libadwaita ];
      };
      deepseek-harness = super.callPackage ./deekseek-harness/package.nix { };
      # ShojiWM is vendored from a pinned upstream commit and built from the
      # fetched tree's own nix/package.nix (see ./shojiwm/package.nix); bump
      # rev/hash via ./shojiwm/update.sh.
      shojiwm = super.callPackage ./shojiwm/package.nix {
        libgbm = super.libgbm or super.mesa;
        xwayland = super.xwayland or (super.xorg.xwayland or null);
        xwaylandSatellite = super.xwayland-satellite or null;
      };
    })
  ];
}
