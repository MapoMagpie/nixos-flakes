{
  callPackage,
  fetchFromGitHub,
  runCommand,
  libgbm,
  xwayland,
  xwaylandSatellite,
}:

# ShojiWM is built purely from upstream's own packaging, vendored from a pinned
# commit. The upstream `nix/package.nix` (and its `rusty-v8.nix` colleague) lives
# inside the fetched source tree, so all build internals — the cargo lockfile,
# git-dep hashes, the embedded rusty_v8 archive — are owned upstream and tracked
# at the pinned revision. To update, bump `rev` / `hash` via ./update.sh.
#
# Local fix: upstream pins a stale outputHash for its `smithay` git dependency
# (`smithay-0.7.0` and `smithay-drm-extras-0.1.0` both come from
# bea4dev/smithay at the same rev, so they share one hash) — the pinned value
# does not match the actual checkout, so the fetchgit fails with a hash
# mismatch. `smithay-outputhash.patch` corrects it and is applied onto the
# fetched source (a plain overrideAttrs fix would be lost because
# nixos-module.nix re-derives the package via `.override`). update.sh
# regenerates the patch from the new source when the smithay rev moves; drop
# the patch and this step once upstream fixes the hash.

let
  rev = "cb582acbcf61eb174c8bbd1b6ec935589365dcb5";

  src = fetchFromGitHub {
    owner = "bea4dev";
    repo = "ShojiWM";
    inherit rev;
    hash = "sha256-fKR7FfGo6aj3QdQFYoDAw0Hozd+QTVG5PFi5n/EUuoM=";
  };

  # Source with the stale smithay outputHash corrected (see comment above).
  src' = runCommand "shojiwm-src" { } ''
    cp -a ${src} $out
    chmod -R u+w $out
    patch -p1 -d "$out" < ${./smithay-outputhash.patch}
  '';
in
callPackage (src' + "/nix/package.nix") {
  inherit libgbm xwayland xwaylandSatellite;
}
