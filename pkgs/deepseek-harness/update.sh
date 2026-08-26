#!/usr/bin/env nix-shell
#! nix-shell -i bash -p bash nix jq curl

set -euo pipefail

REPO="moraxyc/deepseek-harness.nix"
BRANCH="main"
DIR="$(cd "$(dirname "$0")" && pwd)"
PKG="$DIR/package.nix"

# --- 1. latest commit on main ----------------------------------------------
latest="$(curl ${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} -fsS \
  "https://api.github.com/repos/$REPO/commits/$BRANCH" | jq -r '.sha')"
if [ -z "$latest" ] || [ "$latest" = "null" ]; then
  echo "error: could not fetch latest $BRANCH commit from $REPO" >&2
  exit 1
fi

current="$(grep -oP 'rev = "\K[0-9a-f]{40}' "$PKG")"

if [ "$latest" = "$current" ]; then
  echo "up-to-date ($current)"
  exit 0
fi

echo "bumping $current -> $latest"

# --- 2. fetchFromGitHub nar hash for the new rev ---------------------------
hash="$(nix-prefetch-url --unpack --type sha256 \
  "https://github.com/$REPO/archive/$latest.tar.gz")"
sri="$(nix hash to-sri --type sha256 "$hash")"

# --- 3. patch package.nix in place -----------------------------------------
sed -i "s|rev = \"$current\"|rev = \"$latest\"|" "$PKG"
sed -i "s|hash = \"sha256-[^\"]*\"|hash = \"$sri\"|" "$PKG"

echo "updated to $latest (hash $sri)"