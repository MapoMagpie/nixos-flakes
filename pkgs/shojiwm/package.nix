{
  callPackage,
  fetchFromGitHub,
  libgbm,
  xwayland,
  xwaylandSatellite,
}:

# ShojiWM is built purely from upstream's own packaging, vendored from a
# pinned commit of bea4dev/ShojiWM. The upstream `nix/package.nix` (and its
# `rusty-v8.nix` colleague) lives inside the fetched source tree, so all
# build internals — the cargo lockfile, git-dep outputHashes (smithay fork
# rev, rustyscript), the embedded rusty_v8 archive — are owned upstream and
# tracked at the pinned revision. To update, bump `rev` / `hash` via
# ./update.sh (it also verifies the git-dep outputHashes against the actual
# checkouts, since upstream has shipped stale smithay hashes before).
#
# No local patch is needed at the pinned rev: upstream fixed the smithay
# outputHash in 40e99b7 ("nix: fix smithay outputHashes after fork rev bump").

let
  rev = "661a35838f953e3725b7328ab0e2f566b5f3c196";

  src = fetchFromGitHub {
    owner = "bea4dev";
    repo = "ShojiWM";
    inherit rev;
    hash = "sha256-8zV+tjcv5mnHiFO5EuHVZIfyw4Toy1OyK5mqDbXwsK8=";
  };
in
callPackage (src + "/nix/package.nix") {
  inherit libgbm xwayland xwaylandSatellite;
}
