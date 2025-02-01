{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      niri,
      ...
    }:
    {
      nixpkgs.overlays = [ niri.overlays.niri ];
      nixosConfigurations.maponixos =
        let
          host = import ./variables.nix "maponixos";
        in
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit host;
          };
          modules = [
            ./nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.backupFileExtension = "bak";
              home-manager.extraSpecialArgs = {
                inherit host;
                inherit niri;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users."${host.username}" = import ./home;
            }

          ];
        };
    };
}
