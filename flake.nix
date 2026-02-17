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
  };

  outputs =
    {
      nixpkgs,
      nix-maid,
      rimedm,
      helix,
      rust-overlay,
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
            inherit rimedm;
            inherit helix;
          };
          modules = [
            nix-maid.nixosModules.default
            ./nixos
          ];
        };

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [
          rust-overlay.overlays.default
        ];
      };
      rust = pkgs.rust-bin.stable.latest.default.override {
        extensions = [ "rust-src" ];
      };
      rust-wasm = pkgs.rust-bin.stable.latest.default.override {
        targets = [ "wasm32-unknown-unknown" ];
        extensions = [ "rust-src" ];
      };
    in
    {
      nixosConfigurations.maponixos = nixosSystem "maponixos";
      nixosConfigurations.slavenixos = nixosSystem "slavenixos";
      devShells."x86_64-linux" = {
        rust = pkgs.mkShell {
          packages = with pkgs; [
            rust
            rust-analyzer-unwrapped
            copilot-language-server
          ];
          RUST_SRC_PATH = "${rust}/lib/rustlib/src/rust/library";
        };
        rust-wasm = pkgs.mkShell {
          packages = with pkgs; [
            rust-wasm
            rust-analyzer-unwrapped
            wasm-pack
            wasm-bindgen-cli
            copilot-language-server
          ];
          RUST_SRC_PATH = "${rust}/lib/rustlib/src/rust/library";
        };
        ts = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_24
            typescript-language-server
            copilot-language-server
          ];
        };
        go = pkgs.mkShell {
          packages = with pkgs; [
            go
            gopls
            gotools
            go-tools
            copilot-language-server
          ];
        };
        lua = pkgs.mkShell {
          packages = with pkgs; [
            lua
            lua-language-server
          ];
        };
      };
    };
}
