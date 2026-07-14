{ ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      github-copilot-cli = super.callPackage ./github-copilot-cli/package.nix { };
      flyline = super.callPackage ./flyline/package.nix { };
    })
  ];
}
