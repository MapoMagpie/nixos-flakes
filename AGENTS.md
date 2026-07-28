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
Custom packages in `pkgs/` are exposed through `nixpkgs.overlays` in `pkgs/overlays.nix`. They use `callPackage` and are available as `pkgs.<name>` in all modules — no need to thread them through flake inputs.

### Flake inputs with follows
All flake inputs use `inputs.*.follows = "nixpkgs"` to pin to a single nixpkgs revision, preventing duplicate dependency trees.

### Private/patched software
Personal forks of upstream projects (helix, rimedm) are referenced as flake inputs with `github:MapoMagpie/<repo>`. Some carry local patches; check the fork's branch/commits before modifying derivation internals.
