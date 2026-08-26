{
  lib,
  pkgs,
  fetchFromGitHub,
}:

let
  # The upstream packaging project moraxyc/deepseek-harness.nix is pinned as
  # a whole at a commit; refresh via ./update.sh (bumps `rev` + `hash` only).
  # Every packaging internal (dsh-kernel, dsh-workspace and its pnpm lock,
  # bundles, hooks, importPnpmLock) is owned upstream at that revision, so
  # upstream build-dependency changes never need local edits.
  src = fetchFromGitHub {
    owner = "moraxyc";
    repo = "deepseek-harness.nix";
    rev = "052163e61ec9bc5180cb036a0da0ff4a0440542d";
    hash = "sha256-von7BapFOfsZB6NawXYqd9XJnyjUyiHQwKzKRQ3Eifk=";
  };

  # The project exposes its packages through an overlay whose `dsh` attribute
  # is a callPackage scope (dsh, dsh-kernel, dsh-workspace, bundles, hooks,
  # importPnpmLock) built against the caller's package set — exactly
  # upstream's `pkgs.dsh.dsh` for the composed package.
  upstream = (import "${src}/overlays/default.nix") pkgs { };
  dshPackage = upstream.dsh.dsh;
in
# The composed `dsh` package: kernel + default bundles (headless, web-app)
# + profile machinery.
dshPackage // {
  passthru = dshPackage.passthru // {
    updateScript = ./update.sh;
  };
}