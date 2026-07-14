{
  lib,
  stdenv,
  rustPlatform,
  fetchurl,
  installShellFiles,
  runCommand,
  git,
}:

rustPlatform.buildRustPackage rec {
  pname = "helix";
  version = "v20260714";

  src = fetchurl {
    url = "https://github.com/MapoMagpie/helix/releases/download/${version}/helix-source.tar.xz";
    hash = "sha256-l2r1FIQ6dHyQsJ2JEuKbyd6zBJJo6JWU/4Qf9YvnPQI=";
  };

  # tarball 直接解压到当前目录（非子目录），需显式指定
  sourceRoot = ".";

  # Cargo.lock 必须在 eval 阶段可用，源码包在 build 阶段才下载，
  # 所以这里本地保留一份 → 等同于原 default.nix 中 cargoLock.lockFile = ./Cargo.lock
  cargoLock = {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  # 预编译 runtime 替代 grammars.nix 的 IFD 构建
  runtime = fetchurl {
    url = "https://github.com/MapoMagpie/helix/releases/download/${version}/helix-runtime.tar.xz";
    hash = "sha256-h5QXXOQflEgMQ85BwmYFiWASV91L5lQx0cnK2pQij2w=";
  };

  runtimeDir = runCommand "helix-runtime" { } ''
    mkdir -p $out
    tar xf ${runtime} -C $out --strip-components=1
  '';

  propagatedBuildInputs = [ runtimeDir ];

  nativeBuildInputs = [
    installShellFiles
    git
  ];

  buildType = "release";
  doCheck = false;
  strictDeps = true;

  HELIX_DISABLE_AUTO_GRAMMAR_BUILD = "1";
  HELIX_NIX_BUILD_REV = version;
  env.HELIX_DEFAULT_RUNTIME = "${runtimeDir}";

  postInstall = ''
    installShellCompletion --cmd hx \
      --bash contrib/completion/hx.bash \
      --fish contrib/completion/hx.fish \
      --zsh  contrib/completion/hx.zsh

    mkdir -p $out/share/{applications,icons/hicolor/{256x256,scalable}/apps}
    cp contrib/Helix.desktop $out/share/applications/Helix.desktop
    cp logo.svg $out/share/icons/hicolor/scalable/apps/helix.svg
    cp contrib/helix.png $out/share/icons/hicolor/256x256/apps/helix.png
  '';

  meta = {
    description = "A post-modern text editor (MapoMagpie fork)";
    homepage = "https://github.com/MapoMagpie/helix";
    license = lib.licenses.mpl20;
    mainProgram = "hx";
    platforms = lib.platforms.linux;
  };
}
