{
  lib,
  stdenv,
  autoPatchelfHook,
  fetchurl,
  glib,
  libsecret,
  versionCheckHook,
}:
let
  arch =
    with stdenv.hostPlatform;
    if isx86_64 then
      "x64"
    else if isAarch64 then
      "arm64"
    else
      throw "Unsupported arch: ${stdenv.hostPlatform.system}";
  platform = if stdenv.hostPlatform.isDarwin then "darwin-${arch}" else "linux-${arch}";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "github-copilot-cli";
  version = "1.0.77";

  src = fetchurl {
    url = "https://github.com/github/copilot-cli/releases/download/v${finalAttrs.version}/copilot-${platform}.tar.gz";
    hash =
      {
        "x86_64-darwin" = "sha256-fIP8FgF6Z7ezVN/KGakzQnNdLscQ+2DMF0QHlYq2cCw=";
        "aarch64-darwin" = "sha256-Ork2bNlsBuTZDG5316n/oG4lAqoRlrogxVUwbA16lZI=";
        "x86_64-linux" = "sha256-xkFPmcWymwSaOwkpuoJPD/CuiLhetSVZvkVjG5awD0w=";
        "aarch64-linux" = "sha256-W88BswvXTOQVzJOstASIXgvDls3gN8po7+K47IT5Hlo=";
      }
      .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
    glib
    libsecret
  ];

  # tarball contains only a single `copilot` binary (no directory)
  sourceRoot = ".";

  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"/bin
    cp copilot "$out"/bin/
    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "GitHub Copilot CLI brings the power of Copilot coding agent directly to your terminal";
    homepage = "https://github.com/github/copilot-cli";
    changelog = "https://github.com/github/copilot-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [
      dbreyfogle
      me-and
    ];
    mainProgram = "copilot";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
})
