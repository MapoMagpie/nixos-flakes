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

    quickshell.url = "github:quickshell-mirror/quickshell";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";

    matugen.url = "github:iniox/matugen"; # upstream
    matugen.inputs.nixpkgs.follows = "nixpkgs";

    swww.url = "github:LGFae/swww";
    swww.inputs.nixpkgs.follows = "nixpkgs";

    # zen-browser.url = "github:0xc000022070/zen-browser-flake";
    # # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
    # # to have it up-to-date or simply don't specify the nixpkgs input
    # zen-browser.inputs.nixpkgs.follows = "nixpkgs";
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
    let
      nixosSystem =
        hostname:
        let
          host = import ./variables.nix hostname;
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
    in
    {
      nixpkgs.overlays = [ niri.overlays.niri ];
      nixosConfigurations.maponixos = nixosSystem "maponixos";
    };
}
