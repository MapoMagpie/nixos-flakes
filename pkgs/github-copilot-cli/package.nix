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
  version = "1.0.75";

  src = fetchurl {
    url = "https://github.com/github/copilot-cli/releases/download/v${finalAttrs.version}/copilot-${platform}.tar.gz";
    hash =
      {
        "x86_64-darwin" = "sha256-6AeNV6zMfqu7KVZaL0whdyOs+3x6JWPtbKxBxF6yms8=";
        "aarch64-darwin" = "sha256-pe3g2W27bP/4vtD2hyrD6wW/Ck7TQtRKCmVIyyQnE8I=";
        "x86_64-linux" = "sha256-0wTvZsDB0t59c2s2U7NlV+gLT0Cgv4xKcechXzr/dEE=";
        "aarch64-linux" = "sha256-CRHxLdgW9hLSfEo2DU8Ati2TOEWpjWyRPo10AKacaAk=";
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
