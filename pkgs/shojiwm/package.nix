{
  callPackage,
  fetchFromGitHub,
  libgbm,
  xwayland,
  xwaylandSatellite,
}:

# ShojiWM is built purely from upstream's own packaging, vendored from a
# pinned commit of the MapoMagpie fork's `fix/cursor-reappear` branch (main
# plus the pointer-motion fix for cursor re-appearing on layer/popup
# refresh). The upstream `nix/package.nix` (and its `rusty-v8.nix`
# colleague) lives inside the fetched source tree, so all build internals —
# the cargo lockfile, git-dep outputHashes (smithay fork rev, rustyscript),
# the embedded rusty_v8 archive — are owned upstream and tracked at the
# pinned revision. To update, bump `rev` / `hash` via ./update.sh (it also
# verifies the git-dep outputHashes against the actual checkouts, since
# upstream has shipped stale smithay hashes before).
#
# No local patch is needed at the pinned rev: upstream fixed the smithay
# outputHash in 40e99b7 ("nix: fix smithay outputHashes after fork rev bump").

let
  rev = "2867096f994424bf61d9ddf0bee329b60aa17087";

  src = fetchFromGitHub {
    owner = "MapoMagpie";
    repo = "ShojiWM";
    inherit rev;
    hash = "sha256-P6PGEr/kssgvWksG91/yQH5TUI26XZcJi5V7r9pYJ2g=";
  };
in
callPackage (src + "/nix/package.nix") {
  inherit libgbm xwayland xwaylandSatellite;
}
