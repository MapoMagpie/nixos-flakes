#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash nix jq curl nodejs_24 prefetch-npm-deps python3

set -euo pipefail

PKG_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGE_FILE="$PKG_DIR/package.nix"
NPM_NAME="@deepseek-ai/dsh"
REGISTRY="https://registry.npmjs.org/$NPM_NAME"

currentVersion="$(grep -Po 'version\s*=\s*"\K[^"]+' "$PACKAGE_FILE" | head -n 1)"
latestVersion="$(curl ${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} -sL "$REGISTRY" | jq -r '."dist-tags".latest')"

if [ -z "$latestVersion" ] || [ "$latestVersion" = "null" ]; then
  echo "error: could not fetch latest version of $NPM_NAME from npm registry" >&2
  exit 1
fi

echo "current: $currentVersion, latest: $latestVersion"

if [ "$currentVersion" = "$latestVersion" ]; then
  echo "package is up-to-date: $currentVersion"
  exit 0
fi

TAR_URL="$REGISTRY/-/dsh-$latestVersion.tgz"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# --- 1. bump version string ------------------------------------------------
sed -i "s/version = \"$currentVersion\"/version = \"$latestVersion\"/" "$PACKAGE_FILE"

# --- 2. src hash (flat hash of the npm tarball) ----------------------------
echo "fetching $TAR_URL ..."
srcHash="$(nix-prefetch-url --type sha256 "$TAR_URL")"
srcSRI="$(nix hash to-sri --type sha256 "$srcHash")"
echo "  src hash: $srcSRI"
sed -i "s|hash = \"sha256-[^\"]*\"|hash = \"$srcSRI\"|" "$PACKAGE_FILE"

# --- 3. regenerate version-sensitive patches from the new tarball -----------
curl -fsSL -o "$TMP/dsh.tgz" "$TAR_URL"
mkdir -p "$TMP/src"
tar xzf "$TMP/dsh.tgz" -C "$TMP/src"
SRCPKG="$(find "$TMP/src" -mindepth 1 -maxdepth 1 -type d | head -n 1)"

# strip the devDependencies block (workspace-only packages that npm would
# otherwise install because the tarball is the derivation's root)
python3 - "$SRCPKG/package.json" "$TMP/package.json.stripped" <<'PY'
import json, pathlib, sys
raw = pathlib.Path(sys.argv[1]).read_text()
data = json.loads(raw)
data.pop("devDependencies", None)
text = json.dumps(data, indent=2, ensure_ascii=False)
if raw.endswith("\n"):
    text += "\n"
pathlib.Path(sys.argv[2]).write_text(text)
PY

mkpatch() { # <rel-path-in-src> <stripped-file> <out-patch>
  local rel="$1" stripped="$2" out="$3" df
  printf 'diff --git a/%s b/%s\n' "$rel" "$rel" > "$out"
  set +e
  diff -u "$SRCPKG/$rel" "$stripped" > "$TMP/mkpatch.diff"
  df=$?
  set -e
  # exit 1 means "files differ" — the normal case when producing a patch
  case "$df" in
    0) ;;
    1) ;;
    *)
      echo "error: diff failed for $rel (exit $df)" >&2
      exit 1
      ;;
  esac
  sed -e "1s|^--- .*|--- a/$rel|" -e "2s|^+++ .*|+++ b/$rel|" \
    "$TMP/mkpatch.diff" >> "$out"
}
mkpatch "package.json" "$TMP/package.json.stripped" "$PKG_DIR/remove-dev-dependencies.patch"

# point the terminal backend at the Nix-provided bash (@bash@ is substituted
# in postPatch); regenerated so the hunk follows upstream formatting changes
python3 - "$SRCPKG/config/agent-presets/minimal/agent.cordis.yml" "$TMP/agent.cordis.yml.patched" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
lines = p.read_text().splitlines(keepends=False)
out, i, in_bash, after_config = [], 0, False, False
while i < len(lines):
    line = lines[i]
    out.append(line)
    if not in_bash and line.strip() == "- id: terminal-bash":
        in_bash = True
    elif in_bash and not after_config and line.strip() == "config:":
        out.append("        shellPath: @bash@")
        after_config = True
    i += 1
pathlib.Path(sys.argv[2]).write_text("\n".join(out) + "\n")
PY
mkpatch "config/agent-presets/minimal/agent.cordis.yml" \
  "$TMP/agent.cordis.yml.patched" "$PKG_DIR/use-nix-bash.patch"

# --- 4. regenerate package-lock.json from the patched source ---------------
LOCKGEN="$TMP/lockgen"
cp -r "$SRCPKG" "$LOCKGEN"
python3 - "$SRCPKG/package.json" "$LOCKGEN/package.json" <<'PY'
import json, pathlib, sys
raw = pathlib.Path(sys.argv[1]).read_text()
data = json.loads(raw)
data.pop("devDependencies", None)
text = json.dumps(data, indent=2, ensure_ascii=False)
if raw.endswith("\n"):
    text += "\n"
pathlib.Path(sys.argv[2]).write_text(text)
PY
(
  cd "$LOCKGEN"
  npm install --package-lock-only --ignore-scripts --no-audit --no-fund
)
cp "$LOCKGEN/package-lock.json" "$PKG_DIR/package-lock.json"

# paranoid sanity: each @deepseek-ai/dsh-* sibling should be pinned at the
# same rc as dsh itself; anything else means npm resolved a mixed release
# train and the lock needs review before committing
mismatches="$(jq -r --arg rc "$latestVersion" '
  .packages | to_entries[]
    | select(.key | test("^node_modules/@deepseek-ai/dsh-[^/]+$"))
    | .value.version as $v | select($v == null or $v != $rc)
    | "\(.key): \($v)"
' "$PKG_DIR/package-lock.json" || true)"
if [ -n "$mismatches" ]; then
  echo "warning: lockfile pins these @deepseek-ai/dsh-* siblings at versions != $latestVersion:" >&2
  echo "$mismatches" >&2
  echo "  (review before committing; ideally they release in lockstep)" >&2
fi

# --- 5. npmDepsHash ----------------------------------------------------------
echo "computing npmDepsHash ..."
npmDepsHash="$(prefetch-npm-deps "$PKG_DIR/package-lock.json")"
echo "  npmDepsHash: $npmDepsHash"
sed -i "s|npmDepsHash = \"sha256-[^\"]*\"|npmDepsHash = \"$npmDepsHash\"|" "$PACKAGE_FILE"

echo "updated to $latestVersion"