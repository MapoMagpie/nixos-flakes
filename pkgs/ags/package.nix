{
  lib,
  symlinkJoin,
  buildGoModule,
  buildNpmPackage,
  wrapGAppsHook3,
  gobject-introspection,
  glib,
  gjs,
  bash,
  nodejs,
  dart-sass,
  libsoup_3,
  blueprint-compiler,
  coreutils,
  installShellFiles,
  gtk4-layer-shell,
  fetchFromGitHub,
  # Astal packages (provided by flake input via overlay)
  astal3,
  astal4,
  astal-io,
  extraPackages ? [ ],
}:
let
  pname = "ags";
  version = "3.1.2";

  src = fetchFromGitHub {
    owner = "Aylur";
    repo = "ags";
    rev = "v${version}";
    hash = "sha256-tM3s7CX+tgxlYW0Sk3nzVThg2MHn08foIuMxABupxIs=";
  };

  buildInputs =
    extraPackages
    ++ [
      glib
      astal-io
      astal3
      astal4
      gobject-introspection
      libsoup_3
    ];

  bins = [
    gjs
    nodejs
    dart-sass
    blueprint-compiler
    bash
    coreutils
  ];

  girDirs = let
    depsOf = pkg:
      [ (pkg.dev or pkg) ]
      ++ (map depsOf (pkg.propagatedBuildInputs or [ ]));
  in
    symlinkJoin {
      name = "gir-dirs";
      paths = lib.flatten (map depsOf buildInputs);
    };

  gjsPackage = buildNpmPackage {
    name = "ags-js-lib";
    src = lib.cleanSourceWith {
      src = src;
      filter = path: type: let
        relPath = lib.removePrefix (toString src) (toString path);
      in
        builtins.any (p: lib.hasPrefix p relPath) [
          "/lib"
          "/package.json"
          "/package-lock.json"
        ];
    };
    dontBuild = true;
    npmDepsHash = "sha256-jEfEdPmEr4/i5an44WVQoO61w85KPKd2DDkxsSZCNpk=";
    installPhase = ''
      mkdir -p $out/lib
      mkdir -p $out/node_modules
      cp -r lib/* $out/lib
      cp -r node_modules/gnim $out/node_modules
      cp -r package.json $out/package.json
      cp -r package-lock.json $out/package-lock.json
    '';
  };
in
buildGoModule {
  inherit pname version buildInputs;

  src = "${src}/cli";

  vendorHash = "sha256-UHMHbUGqJeUTw0AHHyTdQ8ed5z+SFyPcdXs4shC+hoI=";
  proxyVendor = true;

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
    installShellFiles
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix EXTRA_GIR_DIRS : "${girDirs}/share/gir-1.0"
      --prefix PATH : "${lib.makeBinPath (bins ++ extraPackages)}"
    )
  '';

  postInstall = ''
    installShellCompletion \
      --cmd ags \
      --bash <($out/bin/ags completion bash) \
      --fish <($out/bin/ags completion fish) \
      --zsh <($out/bin/ags completion zsh)

    mkdir -p $out/share/ags/js
    cp -r ${gjsPackage}/* $out/share/ags/js
  '';

  ldflags = [
    "-X main.agsJsPackage=${gjsPackage}"
    "-X main.gtk4LayerShell=${gtk4-layer-shell}/lib/libgtk4-layer-shell.so"
    "-X main.gjs=${gjs}/bin/gjs"
    "-X main.bash=${bash}/bin/bash"
    "-X main.cat=${coreutils}/bin/cat"
    "-X main.base64=${coreutils}/bin/base64"
  ];

  passthru = {
    jsPackage = gjsPackage;
  };

  meta = {
    homepage = "https://github.com/Aylur/ags";
    description = "Scaffolding CLI tool for Astal+Gnim projects";
    license = lib.licenses.gpl3Plus;
    mainProgram = "ags";
    platforms = lib.platforms.linux;
  };
}
