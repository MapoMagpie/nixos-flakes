# Copilot Instructions for nixos-flakes

## Build & Test Commands

```bash
# Rebuild and switch to the current flake configuration (primary workflow)
sudo nixos-rebuild switch --fast --flake ~/nixos

# Update all flake inputs
nix flake update

# Enter a development shell (shell names: rust, wasm, cpp, fcitx5-android, ts, go, lua)
nix develop ~/nixos#<shell-name>
# or use the shell alias: nd <shell-name>

# Format Nix files
nixfmt <file.nix>

# Check Nix syntax without building
nix-instantiate --parse <file.nix>
```

## Architecture

This is a NixOS flake managing three machines (`maponixos`, `slavenixos`, `slavenixostwo`).

**Configuration flow:**
1. `flake.nix` → calls `mkConfiguration` with a host attrset from `hosts/default.nix`
2. Host attrset provides feature flags (`enable_ui`, `enable_game`, `enable_server`, `enable_ui_master`) and hardware path
3. `system/default.nix` imports modules conditionally based on those flags, then imports `home/` for user dotfiles

**Directory roles:**
- `hosts/` — Per-machine definitions: hardware, screen dimensions, feature toggles, user details. Add new hosts here.
- `system/` — OS-level modules (fonts, networking, portal, programs). Modules use `{ host, pkgs, ... }` and gate behavior on `host.enable_*` flags.
- `home/` — User dotfiles. `home/default.nix` generates a shell script run by a `systemd.user.services.dotfiles-activation` oneshot service that symlinks configs into `$HOME` from the nix store.
- `pkgs/` — Custom package derivations registered via `nixpkgs.overlays` in `pkgs/overlays.nix`. Available everywhere as `pkgs.<name>`.
- `devshells/` — Pre-configured development shells with language toolchains, LSP servers, and environment variables.
- `external/` — Git-ignored directory for local assets, work-in-progress projects, and scripts.

## Key Conventions

### Host feature flags
Hosts are defined as attrsets in `hosts/default.nix` with boolean flags controlling what gets imported. When adding new conditional modules, gate on these flags:
- `host.enable_ui` — wayland compositor, desktop apps, fonts
- `host.enable_ui_master` — additional dev tools (codex, claude-code, chromium)
- `host.enable_game` — steam, prismlauncher
- `host.enable_server` — qbittorrent, logind tweaks

### Dotfile management pattern
User configs use a two-layer pattern:
1. Build text-based configs with `pkgs.writeText` (goes into nix store)
2. Symlink them into `$HOME` via `mkLinkCommands` in `home/default.nix`

Config directories that need runtime mutability (not read-only store paths) are linked directly from `external/` or `home/` subdirectories.

### Custom packages via overlays
Custom packages in `pkgs/` are exposed through `nixpkgs.overlays` in `pkgs/overlays.nix`. They use `callPackage` and are available as `pkgs.<name>` in all modules — no need to thread them through flake inputs. Some packages need extra deps threaded from the overlay (see `shojiwm`, `ags`).

### Package directory layout
Each package lives in `pkgs/<name>/` with a `package.nix` entry point that `callPackage` evaluates. Packages that ship release binaries or track a commit pair a `passthru.updateScript = ./update.sh;` in `package.nix` with an executable `update.sh` (nix-shell shebang), so `./pkgs/<name>/update.sh` refreshes the version and hashes in place.

### Packaging strategies by package
The packages in `pkgs/` follow three packaging strategies; pick the one matching the upstream's release model:

1. **Prebuilt release binaries** (`github-copilot-cli`, `flyline`) — `fetchurl` the per-platform tarball from GitHub releases, `autoPatchelfHook` on Linux, store hashes in a per-system attrset. A `let target = { ... }.${system}` block maps system → platform triple/url-suffix; keep this block immutable across updates (it is NOT a hash map). `update.sh` bumps `version`, re-fetches each platform tarball and patches only the `hash = ...` attrset (match `sha256-` prefixed values only — see the flyline sed scope note below).
2. **Build-from-source with local lockfile** (`helix`, `shojiwm` prior to 2026-07) — `fetchFromGitHub`/`fetchurl` the source, keep a local `Cargo.lock`, use `cargoLock.lockFile = ./Cargo.lock` plus `outputHashes` for git deps. `update.sh` must refresh `src` hash, copy the new `Cargo.lock`, recompute `npmDepsHash` (if any), and discover `outputHashes` for every git dep via `fetchgit`. Avoid when upstream ships its own nix packaging.
3. **Thin wrapper over upstream's own nix packaging** (`shojiwm`, preferred when available) — `fetchFromGitHub` a pinned commit and `callPackage (src + "/nix/package.nix")` the upstream's derivation directly. All build internals (`Cargo.lock`, `outputHashes`, `rusty-v8.nix`, `npmDepsHash`) live inside the fetched source tree and are owned upstream at that revision. `update.sh` only needs to bump `rev` and the `fetchFromGitHub` `hash` (nar hash via `nix-prefetch-url --unpack`). When upstream adds a build dependency (e.g. `rusty-v8.nix`), no local change is needed beyond re-running `update.sh`. Relative paths inside the fetched derivation (`../Cargo.lock`, `./rusty-v8.nix`) resolve relative to the fetched file, not `pkgs/<name>/`. `shojiwm/update.sh` additionally verifies the git-dep `outputHashes` in the new source against the actual checkouts (upstream shipped stale smithay hashes before).

The same overlay call should pass any default deps upstream expects: `libgbm`, `xwayland`, `xwaylandSatellite` for shojiwm; `astal3`/`astal4`/`astal-io` for ags.

### update.sh conventions
- Shebang: `#!/usr/bin/env nix-shell` with `-i bash -p bash nix jq curl` plus any tools needed (`prefetch-npm-deps`, `python3` for the build-from-source cargo strategy).
- Honor `GITHUB_TOKEN` via `curl ${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"}` to avoid API rate limits.
- Release-based scripts bump `version` from the latest GitHub release tag; commit-based scripts (shojiwm) bump `rev` from the latest `main`-branch commit.
- Be idempotent: if current == latest, print "up-to-date" and `exit 0` without touching files.
- Compute hashes with nix store tools: `nix-prefetch-url --unpack --type sha256` (nar hash for unpacked archives) then `nix hash to-sri --type sha256` for the SRI form; `prefetch-npm-deps <package-lock.json>` for `npmDepsHash`; for git-dep `outputHashes`, build `pkgs.fetchgit { ...; sha256 = pkgs.lib.fakeSha256; }` and read the `got: sha256-...` from the mismatch error.
- **flyline sed scope pitfall:** when `package.nix` has TWO attrsets sharing the `"$system" = "..."` key pattern (a `target` map of platform triples AND a `hash` map of sha256 values), the update sed must anchor on `sha256-` (e.g. `s|"<system>" = "sha256-[^"]*"|...|`) so it only rewrites the hash attrset and leaves the target triples untouched.
- A package's `nixos-module.nix` (when present, e.g. `pkgs/shojiwm/nixos-module.nix`) is imported by `system/` and should only reference package outputs (`${pkgs.shojiwm}/bin/...`) — keep it decoupled from the packaging strategy so swapping strategies does not require module edits.


### Flake inputs with follows
All flake inputs use `inputs.*.follows = "nixpkgs"` to pin to a single nixpkgs revision, preventing duplicate dependency trees.

### Private/patched software
Personal forks of upstream projects (helix, rimedm) are referenced as flake inputs with `github:MapoMagpie/<repo>`. Some carry local patches; check the fork's branch/commits before modifying derivation internals. `helix` is built from a source tarball published on the fork's GitHub releases; `rimedm`, `astal`, `ags` and `shojiwm`'s runtime are fetched directly.
