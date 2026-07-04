{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-maid.url = "github:viperML/nix-maid";

    rimedm.url = "github:MapoMagpie/rimedm";
    rimedm.inputs.nixpkgs.follows = "nixpkgs";

    helix.url = "github:MapoMagpie/helix/my-helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    senime.url = "github:MapoMagpie/senime";
    senime.inputs.nixpkgs.follows = "nixpkgs";

    qylock.url = "github:Darkkal44/qylock";
    qylock.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nix-maid,
      rimedm,
      helix,
      rust-overlay,
      senime,
      qylock,
      ...
    }:
    let
      nixosSystem =
        hostname:
        let
          host = import ./variables.nix hostname;
        in
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit
              host
              rimedm
              helix
              senime
              ;
          };
          modules = [
            nix-maid.nixosModules.default
            qylock.nixosModules.default
            ./nixos
          ];
        };

    in
    {
      nixosConfigurations.maponixos = nixosSystem "maponixos";
      nixosConfigurations.slavenixos = nixosSystem "slavenixos";
      nixosConfigurations.slavenixostwo = nixosSystem "slavenixostwo";
      devShells."x86_64-linux" = import ./home/devShells.nix { inherit nixpkgs rust-overlay; };
    };
}
