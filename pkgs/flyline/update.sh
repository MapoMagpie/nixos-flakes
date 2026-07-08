#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash nix jq curl

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/package.nix"

currentVersion=$(grep -Po 'version\s*=\s*"\K[^"]+' "$PACKAGE_FILE")
latestVersion=$(curl ${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} -sL https://api.github.com/repos/HalFrgrd/flyline/releases/latest | jq --raw-output .tag_name | sed 's/^v//')

echo "current: $currentVersion, latest: $latestVersion"

if [[ "$currentVersion" == "$latestVersion" ]]; then
  echo "package is up-to-date: $currentVersion"
  exit 0
fi

# Update version string
sed -i "s/version = \"$currentVersion\"/version = \"$latestVersion\"/" "$PACKAGE_FILE"

# Compute new hashes for each platform
declare -A target_map
target_map=(
  ["x86_64-linux"]="x86_64-unknown-linux-gnu"
  ["aarch64-linux"]="aarch64-unknown-linux-gnu"
  ["x86_64-darwin"]="x86_64-apple-darwin"
  ["aarch64-darwin"]="aarch64-apple-darwin"
)

for system in "${!target_map[@]}"; do
  target="${target_map[$system]}"
  url="https://github.com/HalFrgrd/flyline/releases/download/v${latestVersion}/libflyline-v${latestVersion}-${target}.tar.gz"
  echo "fetching $url ..."
  tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/flyline.tar.gz" "$url"
  hash=$(nix --extra-experimental-features nix-command hash file "$tmp/flyline.tar.gz")
  echo "  hash: $hash"
  # Update hash for this system in package.nix
  sed -i "s|\"$system\" = \"[^\"]*\"|\"$system\" = \"$hash\"|" "$PACKAGE_FILE"
  rm -rf "$tmp"
done

echo "updated to version $latestVersion"
