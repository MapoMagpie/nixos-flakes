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

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            rust-overlay.overlays.default
          ];
        };
      mkRustToochain =
        pkgs:
        pkgs.rust-bin.stable.latest.default.override {
          targets = [ "wasm32-unknown-unknown" ];
          extensions = [ "rust-src" ];
        };
    in
    {
      nixosConfigurations.maponixos = nixosSystem "maponixos";
      nixosConfigurations.slavenixos = nixosSystem "slavenixos";
      devShells."x86_64-linux" =
        let
          pkgs = pkgsFor "x86_64-linux";
          rust = mkRustToochain pkgs;
        in
        {
          rust = pkgs.mkShell {
            packages = with pkgs; [
              rust
              rust-analyzer-unwrapped
            ];
            RUST_SRC_PATH = "${rust}/lib/rustlib/src/rust/library";
          };
          rust-wasm = pkgs.mkShell {
            packages = with pkgs; [
              rust
              rust-analyzer-unwrapped
              wasm-pack
              wasm-bindgen-cli
            ];
            RUST_SRC_PATH = "${rust}/lib/rustlib/src/rust/library";
          };
          ts = pkgs.mkShell {
            packages = with pkgs; [
              nodejs_24
              typescript-language-server
            ];
          };
          go = pkgs.mkShell {
            packages = with pkgs; [
              go
              gopls
              gotools
              go-tools
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
