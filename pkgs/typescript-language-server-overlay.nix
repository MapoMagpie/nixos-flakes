# Overlay fixing the stale `pnpmDeps` hash for typescript-language-server in
# the nixos-unstable revision this flake pins.
#
# Upstream fix: NixOS/nixpkgs#572951 ("typescript-language-server: fix pnpm
# hash"). Drop this overlay once the flake's nixpkgs input contains it.
#
# `fetchPnpmDeps` is `lib.makeOverridable` and maps its `hash` argument to the
# derivation's `outputHash`, so the override must go through `.override`, not
# `.overrideAttrs`.
final: prev: {
  typescript-language-server = prev.typescript-language-server.overrideAttrs (old: {
    pnpmDeps = old.pnpmDeps.override {
      hash = "sha256-xR/EF60lVBsITKgH7wCM2wHM46PFQevD51KfCENSUH4=";
    };
  });
}
