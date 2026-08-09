#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash nix jq curl nix-prefetch-git

# Update the shojiwm package to the latest commit on the ShojiWM `main` branch.
#
# Unlike the release-based updaters for github-copilot-cli and flyline, shojiwm
# tracks an upstream *commit*. ShojiWM's build is vendored straight from the
# upstream source tree (nix/package.nix + nix/rusty-v8.nix), so the only thing
# this script has to refresh here is the pinned `rev` and its fetchFromGitHub
# `hash` in package.nix — all cargo/npm-git hashes are owned upstream and travel
# with the pinned commit.
#
# One exception: upstream pins a stale outputHash for the `smithay` git dep
# (see smithay-outputhash.patch / package.nix). After bumping the pin we
# regenerate that patch from the new source so the hash always matches the
# smithay rev in the new Cargo.lock.

set -euo pipefail

OWNER="bea4dev"
REPO="ShojiWM"
BRANCH="main"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/package.nix"
PATCH_FILE="$SCRIPT_DIR/smithay-outputhash.patch"

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

# Regenerate smithay-outputhash.patch against the new source: the smithay
# git-dep outputHash pinned upstream is stale, so recompute the hash for the
# smithay rev in the new Cargo.lock and re-diff upstream's package.nix against
# the corrected one (patch -p1 paths: a/nix/package.nix, b/nix/package.nix).
if [[ -f "$PATCH_FILE" ]]; then
  tmpDir=$(mktemp -d)
  trap 'rm -rf "$tmpDir"' EXIT

  # The store copy of the archive (already fetched above) is the unpacked
  # source tree when fetched with --unpack.
  newSrcPath=$(nix-prefetch-url --unpack --print-path "$archiveUrl" 2>/dev/null | tail -n1)

  smithayRev=$(
    grep -A3 'name = "smithay"' "$newSrcPath/Cargo.lock" |
      grep -m1 'source = "git' |
      grep -oP 'rev=\K[0-9a-f]+' |
      head -n1 || true
  )

  if [[ -z "${smithayRev:-}" ]]; then
    echo "warning: could not determine smithay rev from the new Cargo.lock; leaving $PATCH_FILE unchanged" >&2
  else
    smithayHash=$(nix-prefetch-git https://github.com/bea4dev/smithay.git "$smithayRev" | jq -r '.hash')

    mkdir -p "$tmpDir/a/nix" "$tmpDir/b/nix"
    cp "$newSrcPath/nix/package.nix" "$tmpDir/a/nix/package.nix"
    cp "$newSrcPath/nix/package.nix" "$tmpDir/b/nix/package.nix"
    sed -i \
      -e "s|\(\"smithay-0\.7\.0\" = \"\)sha256-[^\"]*|\1$smithayHash|" \
      -e "s|\(\"smithay-drm-extras-0\.1\.0\" = \"\)sha256-[^\"]*|\1$smithayHash|" \
      "$tmpDir/b/nix/package.nix"

    if (cd "$tmpDir" && diff -u a/nix/package.nix b/nix/package.nix) >"$PATCH_FILE.tmp"; then
      # No difference: upstream already pins the correct hash.
      rm -f "$PATCH_FILE.tmp"
      echo "note: upstream nix/package.nix already pins the correct smithay hash;"
      echo "      smithay-outputhash.patch is no longer needed — remove it and the runCommand patch step from package.nix"
    else
      mv "$PATCH_FILE.tmp" "$PATCH_FILE"
      echo "  smithay outputHash ($smithayRev): $smithayHash"
    fi
  fi
fi

echo "updated shojiwm to $latestRev ($commitDate)"
echo "  src hash: $srcHash"
