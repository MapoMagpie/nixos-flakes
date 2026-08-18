#!/usr/bin/env nix-shell
#! nix-shell -i bash -p bash nix jq curl nix-prefetch-git

set -euo pipefail

REPO="bea4dev/ShojiWM"
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

# --- 3. verify the new source's git-dep outputHashes -----------------------
# Upstream has shipped stale smithay outputHashes before; check every git dep
# in the new Cargo.lock against nix/package.nix so a broken pin is caught
# here instead of as a fetchgit hash-mismatch mid-build.
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl ${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} -fsSL \
  "https://github.com/$REPO/archive/$latest.tar.gz" | tar xz -C "$tmp"
src="$tmp/ShojiWM-$latest"

bad=0
while read -r name url; do
  [ -n "$name" ] || continue
  rev="$(printf '%s' "$url" | grep -oP 'rev=\K[0-9a-f]{40}')"
  [ -n "$rev" ] || continue
  repo="${url#git+}"
  repo="${repo%%\?*}"
  expected="$(nix-prefetch-git "$repo" "$rev" 2>/dev/null | jq -r .hash)"
  pinned="$(grep -oP "\"$name-[0-9][^\"]*\" = \"\Ksha256-[^\"]+" \
    "$src/nix/package.nix" || true)"
  if [ -z "$pinned" ]; then
    echo "warning: no outputHash pinned for git dep '$name' at $rev" >&2
  elif [ "$expected" != "$pinned" ]; then
    echo "error: stale outputHash for '$name' ($rev):" >&2
    echo "  pinned:   $pinned" >&2
    echo "  correct:  $expected" >&2
    echo "  -> wait for upstream to fix nix/package.nix, or add a local patch" >&2
    bad=1
  fi
done < <(awk '
  /^name = / { name = $3 }
  /source = "git\+/ { gsub(/"/, "", name); gsub(/"/, "", $3); print name, $3 }
' "$src/Cargo.lock" | sort -u)

if [ "$bad" -ne 0 ]; then
  echo "aborting: outputHashes are stale at $latest" >&2
  exit 1
fi

# --- 4. patch package.nix in place -----------------------------------------
sed -i "s|rev = \"$current\"|rev = \"$latest\"|" "$PKG"
sed -i "s|hash = \"sha256-[^\"]*\"|hash = \"$sri\"|" "$PKG"

echo "updated to $latest (hash $sri)"
