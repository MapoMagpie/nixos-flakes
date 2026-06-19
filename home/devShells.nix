{ nixpkgs, rust-overlay, ... }:
let
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
  rust = pkgs.mkShell {
    packages = with pkgs; [
      rust
      rust-analyzer-unwrapped
      rust-bindgen
      copilot-language-server
    ];
    RUST_SRC_PATH = "${rust}/lib/rustlib/src/rust/library";
    shellHook = "source ~/nixos/external/copilot-cli-env.sh";
  };
  wasm = pkgs.mkShell {
    packages = with pkgs; [
      rust-wasm
      wasm-pack
      wasm-bindgen-cli
    ];
  };
  cpp = pkgs.mkShell {
    packages = with pkgs; [
      gcc
      cmake
      ninja
      pkg-config
      fcitx5
      kdePackages.extra-cmake-modules
      gettext
      libclang
      copilot-language-server
    ];
    shellHook = "source ~/nixos/external/copilot-cli-env.sh";
  };
  ts = pkgs.mkShell {
    packages = with pkgs; [
      nodejs_24
      typescript-language-server
      copilot-language-server
    ];
    shellHook = "source ~/nixos/external/copilot-cli-env.sh";
  };
  go = pkgs.mkShell {
    packages = with pkgs; [
      go
      gopls
      gotools
      go-tools
      copilot-language-server
    ];
    shellHook = "source ~/nixos/external/copilot-cli-env.sh";
  };
  lua = pkgs.mkShell {
    packages = with pkgs; [
      lua
      lua-language-server
      copilot-language-server
    ];
    shellHook = "source ~/nixos/external/copilot-cli-env.sh";
  };
}
