#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash nix-update common-updater-scripts nix jq

set -euo pipefail

currentVersion=$(nix-instantiate --eval -E "with import ./. {}; flyline.version or (lib.getVersion flyline)" | tr -d '"')
latestVersion=$(curl ${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} -sL https://api.github.com/repos/HalFrgrd/flyline/releases/latest | jq --raw-output .tag_name | sed 's/^v//')

if [[ "$currentVersion" == "$latestVersion" ]]; then
  echo "package is up-to-date: $currentVersion"
  exit 0
fi

update-source-version flyline $latestVersion || true

for system in \
  x86_64-linux \
  aarch64-linux \
  x86_64-darwin \
  aarch64-darwin; do
  tmp=$(mktemp -d)
  curl -fsSL -o $tmp/flyline $(nix-instantiate --eval -E "with import ./. {}; flyline.src.url" --system "$system" | tr -d '"')
  hash=$(nix --extra-experimental-features nix-command hash file $tmp/flyline)
  update-source-version flyline $latestVersion $hash --system=$system --ignore-same-version
  rm -rf $tmp
done
