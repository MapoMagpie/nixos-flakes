{ ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      github-copilot-cli = super.callPackage pkgs/github-copilot-cli/package.nix { };
    })
  ];
}
