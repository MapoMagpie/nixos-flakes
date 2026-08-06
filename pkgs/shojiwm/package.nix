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
  rev = "8d359058767e4187505e06f4359e1a95a022ba55";

  src = fetchFromGitHub {
    owner = "bea4dev";
    repo = "ShojiWM";
    inherit rev;
    hash = "sha256-E0Yj2RK3jZXmzuiJfJOf1jU1QkD6Wh/+zaWaj6TmWQo=";
  };
in
callPackage (src + "/nix/package.nix") {
  inherit libgbm xwayland xwaylandSatellite;
}
