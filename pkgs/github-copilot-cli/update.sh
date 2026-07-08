#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash nix jq curl

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/package.nix"

currentVersion=$(grep -Po 'version\s*=\s*"\K[^"]+' "$PACKAGE_FILE")
latestVersion=$(curl ${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} -sL https://api.github.com/repos/github/copilot-cli/releases/latest | jq --raw-output .tag_name | sed 's/^v//')

echo "current: $currentVersion, latest: $latestVersion"

if [[ "$currentVersion" == "$latestVersion" ]]; then
  echo "package is up-to-date: $currentVersion"
  exit 0
fi

# Update version string
sed -i "s/version = \"$currentVersion\"/version = \"$latestVersion\"/" "$PACKAGE_FILE"

# Compute new hashes for each platform
declare -A platform_map
platform_map=(
  ["x86_64-linux"]="linux-x64"
  ["aarch64-linux"]="linux-arm64"
  ["x86_64-darwin"]="darwin-x64"
  ["aarch64-darwin"]="darwin-arm64"
)

for system in "${!platform_map[@]}"; do
  platform="${platform_map[$system]}"
  url="https://github.com/github/copilot-cli/releases/download/v${latestVersion}/copilot-${platform}.tar.gz"
  echo "fetching $url ..."
  tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/copilot.tar.gz" "$url"
  hash=$(nix --extra-experimental-features nix-command hash file "$tmp/copilot.tar.gz")
  echo "  hash: $hash"
  # Update hash for this system in package.nix
  sed -i "s|\"$system\" = \"[^\"]*\"|\"$system\" = \"$hash\"|" "$PACKAGE_FILE"
  rm -rf "$tmp"
done

echo "updated to version $latestVersion"
