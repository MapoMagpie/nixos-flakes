{ nixpkgs, rust-overlay, ... }:
let
  pkgs = import nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
    config.android_sdk.accept_license = true;
    overlays = [
      rust-overlay.overlays.default
    ];
  };
  rust = pkgs.rust-bin.stable.latest.default.override {
    extensions = [ "rust-src" ];
  };
  rust-android = pkgs.rust-bin.stable.latest.default.override {
    targets = [
      "aarch64-linux-android"
      "armv7-linux-androideabi"
      "x86_64-linux-android"
      "i686-linux-android"
    ];
    extensions = [ "rust-src" ];
  };
  rust-wasm = pkgs.rust-bin.stable.latest.default.override {
    targets = [ "wasm32-unknown-unknown" ];
    extensions = [ "rust-src" ];
  };

  # Android SDK/NDK composition (matches fcitx5-android/build-logic/convention/src/main/kotlin/Versions.kt)
  androidNdkVersion = "28.0.13004108";
  androidCmakeVersion = "3.31.6";
  androidBuildToolsVersion = "36.1.0";
  androidPlatformVersion = "36";
  androidSdk = pkgs.androidenv.composeAndroidPackages {
    platformToolsVersion = "36.0.2";
    ndkVersion = androidNdkVersion;
    buildToolsVersions = [ androidBuildToolsVersion ];
    platformVersions = [ androidPlatformVersion ];
    cmakeVersions = [ androidCmakeVersion ];
    includeNDK = true;
    includeEmulator = false;
    includeSources = true;
  };
  androidSdkRoot = "${androidSdk.androidsdk}/libexec/android-sdk";
  ndkToolchain = "${androidSdkRoot}/ndk/${androidNdkVersion}/toolchains/llvm/prebuilt/linux-x86_64/bin";
in
{
  rust = pkgs.mkShell {
    packages = with pkgs; [
      rust
      rust-analyzer-unwrapped
      rust-bindgen
      copilot-language-server
    ];
    RUST_SRC_PATH = "${rust}/lib/rustlib/src/rust/library";
    shellHook = "source ~/nixos/external/copilot-cli-env.sh";
  };
  wasm = pkgs.mkShell {
    packages = with pkgs; [
      rust-wasm
      wasm-pack
      wasm-bindgen-cli
    ];
  };
  cpp = pkgs.mkShell {
    packages = with pkgs; [
      llvmPackages.clang
      gcc
      cmake

      pkg-config
      fcitx5
      kdePackages.extra-cmake-modules
      gettext
      copilot-language-server

    ];
    shellHook = ''
      source ~/nixos/external/copilot-cli-env.sh
      # Tell clang/clangd where to find GCC's libstdc++ headers
      export CPLUS_INCLUDE_PATH="${pkgs.gcc.cc}/include/c++/${pkgs.gcc.cc.version}:${pkgs.gcc.cc}/include/c++/${pkgs.gcc.cc.version}/x86_64-unknown-linux-gnu:${pkgs.gcc.cc}/include/c++/${pkgs.gcc.cc.version}/backward:${pkgs.glibc.dev}/include''${CPLUS_INCLUDE_PATH:+:$CPLUS_INCLUDE_PATH}"
    '';
  };
  # Senime + fcitx5-android development environment
  # Merged: Rust (with Android targets) + C++ + Android SDK/NDK
  senime-android = pkgs.mkShell {
    packages = with pkgs; [
      # Rust toolchain with Android cross-compilation targets
      rust-android
      rust-analyzer-unwrapped
      rust-bindgen

      # Android SDK/NDK
      androidSdk.androidsdk

      # C++ / CMake
      kdePackages.extra-cmake-modules
      gettext
      ninja

      # Android Studio (comment out if not needed)
      # androidStudioPackages.beta

      # JDK for Gradle
      jdk17

      # Misc
      python3
      icu
      copilot-language-server
    ];
    ANDROID_SDK_ROOT = androidSdkRoot;
    ANDROID_HOME = androidSdkRoot;
    NDK_VERSION = androidNdkVersion;
    BUILD_TOOLS_VERSION = androidBuildToolsVersion;
    GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdkRoot}/build-tools/${androidBuildToolsVersion}/aapt2";
    ECM_DIR = "${pkgs.kdePackages.extra-cmake-modules}/share/ECM/cmake/";
    JAVA_HOME = "${pkgs.jdk17}";
    RUST_SRC_PATH = "${rust-android}/lib/rustlib/src/rust/library";
    # Cargo linker for Android cross-compilation (minSdk = 23 → API level 23)
    CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER = "${ndkToolchain}/aarch64-linux-android23-clang";
    CARGO_TARGET_ARMV7_LINUX_ANDROIDEABI_LINKER = "${ndkToolchain}/armv7a-linux-androideabi23-clang";
    CARGO_TARGET_X86_64_LINUX_ANDROID_LINKER = "${ndkToolchain}/x86_64-linux-android23-clang";
    CARGO_TARGET_I686_LINUX_ANDROID_LINKER = "${ndkToolchain}/i686-linux-android23-clang";
    shellHook = ''
      source ~/nixos/external/copilot-cli-env.sh
      # Generate local.properties for Gradle
      echo "sdk.dir=$ANDROID_SDK_ROOT" > local.properties 2>/dev/null || true
      # Add Android CMake to PATH
      export PATH="$ANDROID_SDK_ROOT/cmake/${androidCmakeVersion}/bin:$PATH"
    '';
  };
  ts = pkgs.mkShell {
    packages = with pkgs; [
      nodejs_24
      typescript-language-server
      copilot-language-server
    ];
    shellHook = "source ~/nixos/external/copilot-cli-env.sh";
  };
  go = pkgs.mkShell {
    packages = with pkgs; [
      go
      gopls
      gotools
      go-tools
      copilot-language-server
    ];
    shellHook = "source ~/nixos/external/copilot-cli-env.sh";
  };
  lua = pkgs.mkShell {
    packages = with pkgs; [
      lua
      lua-language-server
      copilot-language-server
    ];
    shellHook = "source ~/nixos/external/copilot-cli-env.sh";
  };
}
