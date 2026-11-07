{
  lib,
  stdenv,
  autoPatchelfHook,
  fetchurl,
}:
let
  target =
    {
      "x86_64-linux" = "x86_64-unknown-linux-gnu";
      "aarch64-linux" = "aarch64-unknown-linux-gnu";
      "x86_64-darwin" = "x86_64-apple-darwin";
      "aarch64-darwin" = "aarch64-apple-darwin";
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "flyline";
  version = "1.10.0";

  src = fetchurl {
    url = "https://github.com/HalFrgrd/flyline/releases/download/v${finalAttrs.version}/libflyline-v${finalAttrs.version}-${target}.tar.gz";
    hash =
      {
        "x86_64-linux" = "sha256-/2ZsPI2YLjoLsI0aUVoZ2kcZr0chZJIgyb49AI8mC+s=";
        "aarch64-linux" = "sha256-2hoHeqJ9K9yuEmuiQt/8KDccMu3Y3cbvR/A/R52/WRk=";
        "x86_64-darwin" = "sha256-t7XbyV8IO7jD01ObwlIzkdC1ng9TKFoBd7KgCb2zAU0=";
        "aarch64-darwin" = "sha256-q/cZYsXbZB5xjrOgIdi4V96hV7Gi1Df9DT+aUgdje5c=";
      }
      .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
  ];

  # tarball contains only a single libflyline.so.* file (no directory)
  sourceRoot = ".";

  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib"
    cp libflyline.so.* "$out/lib/libflyline.so"
    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "A readline replacement for Bash written in Rust that provides enhanced line editing experience";
    homepage = "https://github.com/HalFrgrd/flyline";
    changelog = "https://github.com/HalFrgrd/flyline/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
})
