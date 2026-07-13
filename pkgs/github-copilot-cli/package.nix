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
  version = "1.0.70";

  src = fetchurl {
    url = "https://github.com/github/copilot-cli/releases/download/v${finalAttrs.version}/copilot-${platform}.tar.gz";
    hash =
      {
        "x86_64-darwin" = "sha256-zi2Wi2jBooaQVE/2OOdiqASUOZK1SW+37CNY/n8e7oc=";
        "aarch64-darwin" = "sha256-X5eRVh7v6Zs77SWgLu833ENDJwU68F5hUNrX1q7QWjU=";
        "x86_64-linux" = "sha256-Tt7jzQBSVJYHiTKRgZaLIJsXyrR/Q+4TyeBxsffjMJU=";
        "aarch64-linux" = "sha256-HLNYoaisjQ9oC1TG6smQw3YEMxRAmgalqk/tDgp9M2I=";
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
