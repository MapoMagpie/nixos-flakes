{
  callPackage,
  fetchFromGitHub,
  libgbm,
  xwayland,
  xwaylandSatellite,
}:

# ShojiWM is built purely from upstream's own packaging, vendored from a pinned
# commit. The upstream `nix/package.nix` (and its `rusty-v8.nix` colleague) lives
# inside the fetched source tree, so all build internals — the cargo lockfile,
# git-dep hashes, the embedded rusty_v8 archive — are owned upstream and tracked
# at the pinned revision. To update, bump `rev` / `hash` via ./update.sh.

let
  rev = "268c7970912e85dca11e64bbecde8140d8431b26";

  src = fetchFromGitHub {
    owner = "bea4dev";
    repo = "ShojiWM";
    inherit rev;
    hash = "sha256-2hTcsBMQW5kKVnfsC4xsobKlyHFqL3is+d9RpaxO6E0=";
  };
in
callPackage (src + "/nix/package.nix") {
  inherit libgbm xwayland xwaylandSatellite;
}
