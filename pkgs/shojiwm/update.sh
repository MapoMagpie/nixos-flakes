#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash nix jq curl

# Update the shojiwm package to the latest commit on the ShojiWM `main` branch.
#
# Unlike the release-based updaters for github-copilot-cli and flyline, shojiwm
# tracks an upstream *commit*. ShojiWM's build is vendored straight from the
# upstream source tree (nix/package.nix + nix/rusty-v8.nix), so the only thing
# this script has to refresh here is the pinned `rev` and its fetchFromGitHub
# `hash` in package.nix — all cargo/npm-git hashes are owned upstream and travel
# with the pinned commit.

set -euo pipefail

OWNER="bea4dev"
REPO="ShojiWM"
BRANCH="main"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/package.nix"

gh() { curl ${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} -sL "$@"; }

currentRev=$(grep -Po '^\s*rev\s*=\s*"\K[0-9a-f]+' "$PACKAGE_FILE" | head -n1)
if [[ -z "${currentRev:-}" ]]; then
  echo "error: could not determine current rev from $PACKAGE_FILE" >&2
  exit 1
fi

commitInfo=$(gh "https://api.github.com/repos/$OWNER/$REPO/commits/$BRANCH")
latestRev=$(jq -r '.sha' <<<"$commitInfo")
commitDate=$(jq -r '.commit.committer.date' <<<"$commitInfo" | cut -c1-10)

echo "current: $currentRev"
echo "latest:  $latestRev  ($commitDate)"

if [[ "$currentRev" == "$latestRev" ]]; then
  echo "shojiwm is up-to-date: $currentRev"
  exit 0
fi

# fetchFromGitHub hash (nar hash of the unpacked archive).
archiveUrl="https://github.com/$OWNER/$REPO/archive/${latestRev}.tar.gz"
srcHashB32=$(nix-prefetch-url --unpack --type sha256 "$archiveUrl" 2>/dev/null)
srcHash=$(nix hash to-sri --type sha256 "$srcHashB32" 2>/dev/null | awk '{print $1}')

# Patch rev + hash in package.nix.
sed -i "s|\(rev\s*=\s*\"\)[0-9a-f]\+|\1$latestRev|" "$PACKAGE_FILE"
sed -i "s|\(hash\s*=\s*\"\)[^\"]*|\1$srcHash|" "$PACKAGE_FILE"

echo "updated shojiwm to $latestRev ($commitDate)"
echo "  src hash: $srcHash"