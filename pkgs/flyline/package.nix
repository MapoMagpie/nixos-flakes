{
  lib,
  stdenv,
  autoPatchelfHook,
  fetchurl,
}:
let
  target = {
    "x86_64-linux" = "x86_64-unknown-linux-gnu";
    "aarch64-linux" = "aarch64-unknown-linux-gnu";
    "x86_64-darwin" = "x86_64-apple-darwin";
    "aarch64-darwin" = "aarch64-apple-darwin";
  }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "flyline";
  version = "1.7.0";

  src = fetchurl {
    url = "https://github.com/HalFrgrd/flyline/releases/download/v${finalAttrs.version}/libflyline-v${finalAttrs.version}-${target}.tar.gz";
    hash =
      {
        "x86_64-linux" = "sha256-OQSjGxhoKahFBKsMCXaXfPgXUp022rD2t7B4QIz0vbg=";
        "aarch64-linux" = "sha256-1jrTGA0cob0GxRn6QiW/b04bOP1p239u9xKO+rRTNJs=";
        "x86_64-darwin" = "sha256-glGPH70u6TRc6VAKfEA80LGXF5bKD2gXRWXyveVGCPc=";
        "aarch64-darwin" = "sha256-u+OrZRyCgNNnntfB6T0FAVu3DhIsrFPTR9BCH99Eisg=";
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
