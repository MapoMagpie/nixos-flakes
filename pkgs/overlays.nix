{ ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      github-copilot-cli = super.callPackage ./github-copilot-cli/package.nix { };
      flyline = super.callPackage ./flyline/package.nix { };
      helix = super.callPackage ./helix/package.nix { };
      astalPackages = builtins.removeAttrs
        (super.callPackage ./astal/package.nix { })
        [ "override" "overrideDerivation" ];
      ags = super.callPackage ./ags/package.nix {
        inherit (self.astalPackages) astal3 astal4;
        astal-io = self.astalPackages.io;
        extraPackages =
          builtins.attrValues self.astalPackages
          ++ [ super.libadwaita ];
      };
    })
  ];
}
