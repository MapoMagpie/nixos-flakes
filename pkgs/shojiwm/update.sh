#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash nix jq curl prefetch-npm-deps python3

# Update the shojiwm package to the latest commit on the ShojiWM `main` branch.
#
# Unlike the release-based updaters for github-copilot-cli and flyline,
# shojiwm is built from source, so this script refreshes everything that
# deriv:es from the upstream commit:
#   * version          -> "unstable-<commit-date>"
#   * src.rev / src.hash (fetchFromGitHub)
#   * Cargo.lock       -> copied verbatim from the upstream checkout
#   * npmDepsHash      -> recomputed from the upstream package-lock.json
#   * cargoLock.outputHashes -> recomputed for every git dependency, reusing
#     the existing hash when a dependency's git rev did not change.

set -euo pipefail

OWNER="bea4dev"
REPO="ShojiWM"
BRANCH="main"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/package.nix"
CARGO_LOCK="$SCRIPT_DIR/Cargo.lock"
FLAKE_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"

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

newVersion="unstable-${commitDate}"

# Fetch and unpack the upstream source for the new commit.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
archive="$tmp/src.tar.gz"
srcdir="$tmp/src"
gh "https://github.com/$OWNER/$REPO/archive/${latestRev}.tar.gz" -o "$archive"
mkdir -p "$srcdir"
tar -xzf "$archive" -C "$srcdir" --strip-components=1

# 1. fetchFromGitHub source hash (nar hash of the unpacked archive).
archiveUrl="https://github.com/$OWNER/$REPO/archive/${latestRev}.tar.gz"
srcHashB32=$(nix-prefetch-url --unpack --type sha256 "$archiveUrl" 2>/dev/null)
srcHash=$(nix hash to-sri --type sha256 "$srcHashB32" 2>/dev/null | awk '{print $1}')

# 2. npmDepsHash, computed purely from the upstream package-lock.json.
npmDepsHash=$(prefetch-npm-deps "$srcdir/package-lock.json" 2>/dev/null | tail -n1)

# 3. cargoLock.outputHashes for git dependencies.
# discover_git_hash <url> <sha>  ->  prints the SRI sha256 of the fetched git tree.
discover_git_hash() {
  local url="$1" sha="$2"
  nix build --impure --no-link --expr "
    let
      flake = builtins.getFlake \"$FLAKE_ROOT\";
      pkgs = flake.inputs.nixpkgs.legacyPackages.x86_64-linux;
    in pkgs.fetchgit { url = \"$url\"; rev = \"$sha\"; sha256 = pkgs.lib.fakeSha256; }
  " 2>&1 | grep -oE 'got:[[:space:]]*sha256-[A-Za-z0-9+/=]+' | sed -E 's/.*sha256-/sha256-/'
}
export -f discover_git_hash
export FLAKE_ROOT

python3 - \
  "$PACKAGE_FILE" "$CARGO_LOCK" "$srcdir/Cargo.lock" \
  "$newVersion" "$latestRev" "$srcHash" "$npmDepsHash" <<'PYEOF'
import re
import sys
import tomllib
import subprocess

package_file, old_lock_path, new_lock_path, version, rev, src_hash, npm_hash = sys.argv[1:8]


def git_crates(path):
    """Return [(name, version, url, sha)] for every git-sourced crate in a Cargo.lock."""
    with open(path, "rb") as f:
        data = tomllib.load(f)
    out = []
    for pkg in data.get("package", []):
        src = pkg.get("source", "")
        m = re.match(r"git\+([^?]+)(\?(?:rev|tag|branch)=[^#]+)?#(.+)", src)
        if m:
            out.append((pkg["name"], pkg["version"], m.group(1), m.group(3)))
    return out


old_crates = {(n, v): sha for n, v, _u, sha in git_crates(old_lock_path)}
new_git = git_crates(new_lock_path)

txt = open(package_file).read()

# Read the currently pinned outputHashes.
m = re.search(r"outputHashes\s*=\s*\{([^}]*)\};", txt, re.S)
cur = {}
if m:
    for k, v in re.findall(r'"([^"]+)"\s*=\s*"(sha256-[A-Za-z0-9+/=]+)";', m.group(1)):
        cur[k] = v


def discover(url, sha):
    res = subprocess.run(
        ["bash", "-c", 'discover_git_hash "$1" "$2"', "_", url, sha],
        capture_output=True, text=True,
    )
    h = res.stdout.strip()
    if not h.startswith("sha256-"):
        sys.stderr.write(res.stdout + res.stderr)
        raise SystemExit(f"failed to discover git hash for {url} @ {sha}")
    return h


new_oh = {}
seen = {}
for name, ver, url, sha in new_git:
    key = f"{name}-{ver}"
    # Reuse the existing hash when the dependency's git rev is unchanged.
    if key in cur and old_crates.get(key) == sha:
        new_oh[key] = cur[key]
    else:
        if sha not in seen:
            seen[sha] = discover(url, sha)
        new_oh[key] = seen[sha]

if new_oh:
    body = "\n".join(f'      "{k}" = "{new_oh[k]}";' for k in sorted(new_oh))
    oh_block = "outputHashes = {\n" + body + "\n    };"
else:
    oh_block = "outputHashes = {};"
new_txt, n = re.subn(r"outputHashes\s*=\s*\{[^}]*\};", oh_block, txt, count=1, flags=re.S)
if n != 1:
    raise SystemExit("failed to patch the outputHashes block in package.nix")

# Top-level `version` let-binding.
new_txt, n = re.subn(r'(\bversion\s*=\s*")[^"]*(";)', r"\g<1>" + version + r"\g<2>", new_txt, count=1)
if n != 1:
    raise SystemExit("failed to patch version in package.nix")

# fetchFromGitHub rev + hash.
new_txt, n = re.subn(r'(\brev\s*=\s*")[0-9a-f]+(";)', r"\g<1>" + rev + r"\g<2>", new_txt, count=1)
if n != 1:
    raise SystemExit("failed to patch rev in package.nix")
new_txt, n = re.subn(r'(\bhash\s*=\s*")[^"]*(";)', r"\g<1>" + src_hash + r"\g<2>", new_txt, count=1)
if n != 1:
    raise SystemExit("failed to patch src hash in package.nix")

# npmDepsHash.
new_txt, n = re.subn(r'(\bnpmDepsHash\s*=\s*")[^"]*(";)', r"\g<1>" + npm_hash + r"\g<2>", new_txt, count=1)
if n != 1:
    raise SystemExit("failed to patch npmDepsHash in package.nix")

open(package_file, "w").write(new_txt)
print("patched package.nix")
PYEOF

# 4. Refresh Cargo.lock from the upstream checkout.
cp "$srcdir/Cargo.lock" "$CARGO_LOCK"

echo "updated shojiwm to $newVersion ($latestRev)"
echo "  src hash:     $srcHash"
echo "  npmDepsHash:  $npmDepsHash"