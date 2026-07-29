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
  rev = "d9802e3ef34a4477a92e87915c75627b5a78babc";

  src = fetchFromGitHub {
    owner = "bea4dev";
    repo = "ShojiWM";
    inherit rev;
    hash = "sha256-aEwwQ9utsaCKoPC1i4P9RJk5NWQk69xPAYWfuFnJ1qg=";
  };
in
callPackage (src + "/nix/package.nix") {
  inherit libgbm xwayland xwaylandSatellite;
}
