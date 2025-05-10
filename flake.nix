{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    rimedm.url = "github:MapoMagpie/rimedm";
    rimedm.inputs.nixpkgs.follows = "nixpkgs";

    quickshell.url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";

    matugen.url = "github:iniox/matugen"; # upstream
    matugen.inputs.nixpkgs.follows = "nixpkgs";

    swww.url = "github:LGFae/swww";
    swww.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      niri,
      rimedm,
      quickshell,
      matugen,
      swww,
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
            inherit niri;
          };
          modules = [
            ./nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.backupFileExtension = "bak";
              home-manager.extraSpecialArgs = {
                inherit host;
                inherit niri;
                inherit rimedm;
                inherit quickshell;
                inherit matugen;
                inherit swww;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users."${host.username}" = import ./home;
            }
          ] ++ (if host.hostname == "maponixos" then [ ./home/game/steam.nix ] else [ ]);
        };
    };
}
