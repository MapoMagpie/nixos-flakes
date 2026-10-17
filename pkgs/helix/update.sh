#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash nix jq curl coreutils

# Bump pkgs/helix to the latest release of MapoMagpie/helix.
#
# Each release ships two assets that are both fetchurl'd by package.nix:
#   helix-source.tar.xz   -- upstream source tree (contains Cargo.lock)
#   helix-runtime.tar.xz  -- prebuilt runtime (queries, themes, grammars, ...)
#
# Because the source tarball is only downloaded at build time, nix cannot read
# its Cargo.lock during evaluation; pkgs/helix/Cargo.lock is a checked-in copy
# that this script refreshes from the new tarball.

set -euo pipefail

REPO="MapoMagpie/helix"
DIR="$(cd "$(dirname "$0")" && pwd)"
PKG="$DIR/package.nix"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# --- 1. latest release + asset check --------------------------------------
release="$(curl ${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} -fsS \
  "https://api.github.com/repos/$REPO/releases/latest")"
latest="$(printf '%s' "$release" | jq -r '.tag_name')"
if [ -z "$latest" ] || [ "$latest" = "null" ]; then
  echo "error: could not fetch latest release tag from $REPO" >&2
  exit 1
fi

for asset in helix-source.tar.xz helix-runtime.tar.xz; do
  if ! printf '%s' "$release" | jq -e --arg a "$asset" \
    'any(.assets[]; .name == $a)' > /dev/null; then
    echo "error: release $latest is missing asset $asset" >&2
    exit 1
  fi
done

current="$(grep -Po 'version\s*=\s*"\K[^"]+' "$PKG")"
if [ "$current" = "$latest" ]; then
  echo "up-to-date ($current)"
  exit 0
fi
echo "bumping $current -> $latest"

# --- 2. download both assets ----------------------------------------------
base="https://github.com/$REPO/releases/download/$latest"
curl ${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} -fsSL -o "$tmp/helix-source.tar.xz" \
  "$base/helix-source.tar.xz"
curl ${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} -fsSL -o "$tmp/helix-runtime.tar.xz" \
  "$base/helix-runtime.tar.xz"

hash_file() { nix --extra-experimental-features nix-command hash file "$1"; }

newSrcHash="$(hash_file "$tmp/helix-source.tar.xz")"
newRuntimeHash="$(hash_file "$tmp/helix-runtime.tar.xz")"
echo "  source hash:  $newSrcHash"
echo "  runtime hash: $newRuntimeHash"

# --- 3. refresh the checked-in Cargo.lock --------------------------------
# Source tarball unpacks at the top level (package.nix uses sourceRoot = ".").
tar xf "$tmp/helix-source.tar.xz" -C "$tmp" ./Cargo.lock
if [ ! -s "$tmp/Cargo.lock" ]; then
  echo "error: no Cargo.lock found in helix-source.tar.xz" >&2
  exit 1
fi
install -m 0644 "$tmp/Cargo.lock" "$DIR/Cargo.lock"
echo "  Cargo.lock updated"

# --- 4. patch package.nix -------------------------------------------------
# Read the hashes currently in the file so each sed hits exactly one of the
# two `hash = "sha256-..."` lines (src vs. runtime).
oldSrcHash="$(grep -A2 'helix-source\.tar\.xz' "$PKG" | grep -oP 'sha256-[A-Za-z0-9+/=]+' | head -1)"
oldRuntimeHash="$(grep -A2 'helix-runtime\.tar\.xz' "$PKG" | grep -oP 'sha256-[A-Za-z0-9+/=]+' | head -1)"
for h in "$oldSrcHash" "$oldRuntimeHash"; do
  if [ -z "$h" ]; then
    echo "error: could not read existing hashes from $PKG" >&2
    exit 1
  fi
done

sed -i "s|version = \"$current\"|version = \"$latest\"|" "$PKG"
sed -i "s|$oldSrcHash|$newSrcHash|" "$PKG"
sed -i "s|$oldRuntimeHash|$newRuntimeHash|" "$PKG"

echo "updated to $latest"
echo "verify with: nix build ~/nixos#nixosConfigurations.maponixos.pkgs.helix"
