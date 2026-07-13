{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    rimedm.url = "github:MapoMagpie/rimedm";
    rimedm.inputs.nixpkgs.follows = "nixpkgs";

    helix.url = "github:MapoMagpie/helix/my-helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    senime.url = "github:MapoMagpie/senime";
    senime.inputs.nixpkgs.follows = "nixpkgs";

    externalFonts.url = "git+file:./external/assets/fonts";
    externalFonts.inputs.nixpkgs.follows = "nixpkgs";

    externalMedias.url = "git+file:./external/assets/medias";
    externalMedias.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      rimedm,
      helix,
      rust-overlay,
      senime,
      externalFonts,
      externalMedias,
      ...
    }:
    let
      mkHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit rimedm helix senime externalFonts externalMedias; };
          modules = [ ./hosts/${hostname} ];
        };

    in
    {
      nixosConfigurations.maponixos = mkHost "maponixos";
      nixosConfigurations.slavenixos = mkHost "slavenixos";
      nixosConfigurations.slavenixostwo = mkHost "slavenixostwo";
      devShells."x86_64-linux" = import ./home/devShells.nix { inherit nixpkgs rust-overlay; };
    };
}
