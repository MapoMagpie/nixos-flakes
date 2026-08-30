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
  };

  nixConfig = {
    substituters = [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      # deepseek-harness.nix upstream CI pushes prebuilt dsh packages here,
      # which avoids building the whole DeepSeek Harness monorepo locally.
      "https://deepseek-harness-nix.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "deepseek-harness-nix.cachix.org-1:5NrkwLN9veNMhiINtU5ZeV4isXFhFsOwn6Ms7J1M+TA="
    ];
  };

  outputs =
    {
      nixpkgs,
      rimedm,
      helix,
      rust-overlay,
      ...
    }:
    let
      mkConfiguration =
        host:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit rimedm helix host;
          };
          modules = [ ./system ];
        };

    in
    {
      nixosConfigurations.maponixos = mkConfiguration (import ./hosts/default.nix "maponixos");
      nixosConfigurations.slavenixos = mkConfiguration (import ./hosts/default.nix "slavenixos");
      nixosConfigurations.slavenixostwo = mkConfiguration (import ./hosts/default.nix "slavenixostwo");
      devShells."x86_64-linux" = import ./devshells { inherit nixpkgs rust-overlay; };
    };
}
