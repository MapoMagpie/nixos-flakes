{
  fetchFromGitHub,
  fetchFromGitLab,
  stdenv,
  lib,
  formats,
  gobject-introspection,
  wrapGAppsHook3,
  meson,
  pkg-config,
  ninja,
  vala,
  wayland,
  wayland-scanner,
  python3,
  glib,
  gi-docgen,
  gtk3,
  gtk4,
  gtk-layer-shell,
  gtk4-layer-shell,
  json-glib,
  libsoup_3,
  gdk-pixbuf,
  pam,
  networkmanager,
  wireplumber,
  fftw,
  alsa-lib,
  libpulseaudio,
  ncurses,
  iniparser,
  sndio,
  SDL2,
  libGL,
  portaudio,
  jack2,
  pipewire,
  autoreconfHook,
  autoconf-archive,
  pkgconf,
  writeText,
}:
let
  rev = "9dac92f20e6c89b9373bbb238c49b1cb115724db";

  astalSrc = fetchFromGitHub {
    owner = "Aylur";
    repo = "astal";
    rev = rev;
    hash = "sha256-wtypRfcfVvofMON6xemTObJCpPWLRyBoqLrvzgnLYlI=";
  };

  # ── Helper derivations shared by multiple packages ──

  wl-vapi-gen = stdenv.mkDerivation {
    pname = "wl-vapi-gen";
    version = "v1.0.0";
    src = fetchFromGitHub {
      owner = "kotontrion";
      repo = "wl-vapi-gen";
      rev = "1.0.0";
      hash = "sha256-XdgYmxW0ndH6szq7VJ+XQEnWKHCyaWoBwEQREZnTm98=";
    };
    nativeBuildInputs = [ meson ninja python3 ];
    patchPhase = ''
      patchShebangs wl-vapi-gen.py
    '';
  };

  # ── Reusable mkAstalPkg (adapted from astal's nix/mkAstalPkg.nix) ──

  inherit (builtins) elem elemAt readDir readFile replaceStrings splitVersion toJSON;
  inherit (lib) filterAttrs;

  readVer = file: replaceStrings [ "\n" ] [ "" ] (readFile file);

  toTOML = (formats.toml { }).generate;

  gi-docgen-patched = gi-docgen.overrideAttrs {
    patches = [ "${astalSrc}/nix/gi-docgen.patch" ];
  };

  dependency = {
    "GObject-2.0" = {
      name = "GObject";
      description = "The base type system library";
      docs_url = "https://docs.gtk.org/gobject/";
    };
    "Gtk-3.0" = {
      name = "Gtk";
      description = "The GTK toolkit";
      docs_url = "https://docs.gtk.org/gtk3/";
    };
    "Gtk-4.0" = {
      name = "Gtk";
      description = "The GTK toolkit";
      docs_url = "https://docs.gtk.org/gtk4/";
    };
    "AstalIO-0.1" = {
      name = "AstalIO";
      description = "Astal Core library";
      docs_url = "https://docs.astal.dev/io";
    };
    "AstalWl-0.1" = {
      name = "AstalWl";
      description = "A central library to manage wayland objects";
      docs_url = "https://docs.astal.dev/wl";
    };
    "NM-1.0" = {
      name = "NetworkManager";
      description = "The standard Linux network configuration tool suite";
      docs_url = "https://networkmanager.dev/docs/libnm/latest/";
    };
    "WP-0.5" = {
      name = "WirePlumber";
      description = "Modular session/policy manager for PipeWire";
      docs_url = "https://pipewire.pages.freedesktop.org/wireplumber/";
    };
  };

  urlmap = writeText "urlmap" ''
    baseURLs = ${toJSON [
      [ "GLib" "https://docs.gtk.org/glib/" ]
      [ "GObject" "https://docs.gtk.org/gobject/" ]
      [ "Gio" "https://docs.gtk.org/gio/" ]
      [ "Gdk" "https://docs.gtk.org/gdk3/" ]
      [ "Gtk" "https://docs.gtk.org/gtk3/" ]
      [ "GdkPixbuf" "https://docs.gtk.org/gdk-pixbuf/" ]
      [ "AstalIO" "https://docs.astal.dev/io/" ]
      [ "AstalWl" "https://docs.astal.dev/wl/" ]
      [ "NM" "https://networkmanager.dev/docs/libnm/latest/" ]
      [ "WP" "https://pipewire.pages.freedesktop.org/wireplumber/" ]
    ]}
  '';

  mkAstalPkg = {
    src,
    pname,
    libname,
    name,
    authors,
    description,
    dependencies ? [ ],
    repo-path ? libname,
    website-path ? libname,
    nativeBuildInputs ? [ ],
    packages ? [ ],
    postUnpack ? "",
  }:
    let
      ver = readVer "${src}/version";
      splitted = splitVersion ver;
      api-ver = "${elemAt splitted 0}.${elemAt splitted 1}";
      girName = "${name}-${api-ver}";
    in
    stdenv.mkDerivation {
      inherit pname src;
      version = ver;
      outputs = [ "out" "dev" "doc" ];

      nativeBuildInputs =
        [
          wrapGAppsHook3
          gobject-introspection
          meson
          pkg-config
          ninja
          vala
          wayland
          wayland-scanner
          python3
        ]
        ++ nativeBuildInputs;

      propagatedBuildInputs = [ glib ] ++ packages;

      postUnpack = ''
        cp --remove-destination ${astalSrc}/lib/gir.py $sourceRoot/gir.py
        ${postUnpack}
      '';

      postInstall =
        let
          data = toTOML libname {
            library = {
              inherit description authors;
              version = ver;
              license = "LGPL-2.1";
              browse_url = "https://github.com/Aylur/astal/tree/main/lib/${repo-path}";
              repository_url = "https://github.com/aylur/aylur.git";
              website_url = "https://astal.dev/guide/libraries/${website-path}";
              dependencies = [ "GObject-2.0" ] ++ dependencies;
            };
            extra.urlmap_file = "urlmap.js";
            dependencies =
              { inherit (dependency) "GObject-2.0"; }
              // (filterAttrs (n: _: elem n dependencies) dependency);
          };
        in
        ''
          gir="${girName}.gir"

          mkdir -p $out/share/doc/${website-path}
          cat ${urlmap} > urlmap.js

          if [ -d "src" ]; then
            gir="src/$gir"
          fi

          ${gi-docgen-patched}/bin/gi-docgen generate --config ${data} $gir
          mv ${girName}/* $out/share/doc/${website-path}
        '';

      passthru = {
        inherit girName;
      };

      meta = {
        inherit description;
        homepage = "https://astal.dev";
        license = lib.licenses.lgpl21;
      };
    };

  # ── Package-specific helper derivations ──

  libcava = stdenv.mkDerivation rec {
    pname = "cava";
    version = "1.0.0";
    src = fetchFromGitHub {
      owner = "LukashonakV";
      repo = "cava";
      rev = version;
      hash = "sha256-0r5aAmTs+FcmS501tNYKxG9H+Pq6i32BDRBEjWW6M74=";
    };
    buildInputs = [
      alsa-lib
      libpulseaudio
      ncurses
      iniparser
      sndio
      SDL2
      libGL
      portaudio
      jack2
      pipewire
    ];
    propagatedBuildInputs = [ fftw ];
    nativeBuildInputs = [ autoreconfHook autoconf-archive pkgconf meson ninja ];
    preAutoreconf = ''
      echo ${version} > version
    '';
  };

  vala-panel-appmenu = fetchFromGitLab {
    owner = "vala-panel-project";
    repo = "vala-panel-appmenu";
    rev = "25.04";
    hash = "sha256-v5J3nwViNiSKRPdJr+lhNUdKaPG82fShPDlnmix5tlY=";
  };

  appmenu-glib-translator = stdenv.mkDerivation {
    pname = "appmenu-glib-translator";
    version = "25.04";
    src = "${vala-panel-appmenu}/subprojects/appmenu-glib-translator";
    buildInputs = [ glib ];
    nativeBuildInputs = [ gobject-introspection meson pkg-config ninja vala ];
  };

  # Capture nixpkgs packages whose names will be shadowed in the rec scope below
  nix-wireplumber = wireplumber;
in
# ── All astal packages ──
rec {
  io = mkAstalPkg {
    pname = "astal";
    src = "${astalSrc}/lib/astal/io";
    libname = "io";
    name = "AstalIO";
    authors = "Aylur";
    description = "Astal Core library";
    repo-path = "astal/io";
    website-path = "io";
  };

  quarrel = mkAstalPkg {
    pname = "quarrel";
    src = "${astalSrc}/lib/quarrel";
    libname = "quarrel";
    name = "Quarrel";
    authors = "Aylur";
    description = "Command line argument parser.";
  };

  astal3 = mkAstalPkg {
    pname = "astal3";
    src = "${astalSrc}/lib/astal/gtk3";
    packages = [ io gtk3 gtk-layer-shell ];
    libname = "astal3";
    name = "Astal";
    authors = "Aylur";
    description = "Astal GTK3 widget library";
    dependencies = [ "AstalIO-0.1" "Gtk-3.0" ];
    repo-path = "astal/gtk3";
  };

  astal4 = mkAstalPkg {
    pname = "astal4";
    src = "${astalSrc}/lib/astal/gtk4";
    packages = [ io gtk4 gtk4-layer-shell ];
    libname = "astal4";
    name = "Astal";
    authors = "Aylur";
    description = "Astal GTK4 widget library";
    dependencies = [ "AstalIO-0.1" "Gtk-4.0" ];
    repo-path = "astal/gtk4";
  };

  apps = mkAstalPkg {
    pname = "astal-apps";
    src = "${astalSrc}/lib/apps";
    packages = [ json-glib ];
    libname = "apps";
    name = "AstalApps";
    authors = "Aylur";
    description = "Application query library";
  };

  auth = mkAstalPkg {
    pname = "astal-auth";
    src = "${astalSrc}/lib/auth";
    packages = [ pam ];
    libname = "auth";
    name = "AstalAuth";
    authors = "kotontrion";
    description = "Authentication using pam";
  };

  battery = mkAstalPkg {
    pname = "astal-battery";
    src = "${astalSrc}/lib/battery";
    packages = [ json-glib ];
    libname = "battery";
    authors = "Aylur";
    name = "AstalBattery";
    description = "DBus proxy for upowerd devices";
  };

  bluetooth = mkAstalPkg {
    pname = "astal-bluetooth";
    src = "${astalSrc}/lib/bluetooth";
    libname = "bluetooth";
    authors = "Aylur";
    name = "AstalBluetooth";
    description = "DBus proxy for bluez";
  };

  brightness = mkAstalPkg {
    pname = "astal-brightness";
    src = "${astalSrc}/lib/brightness";
    packages = [ quarrel json-glib ];
    libname = "brightness";
    authors = "Aylur";
    name = "AstalBrightness";
    description = "Read and control device brightness";
  };

  cava = mkAstalPkg {
    pname = "astal-cava";
    src = "${astalSrc}/lib/cava";
    packages = [ libcava ];
    libname = "cava";
    authors = "kotontrion";
    name = "AstalCava";
    description = "Audio visualization library using cava";
  };

  greet = mkAstalPkg {
    pname = "astal-greet";
    src = "${astalSrc}/lib/greet";
    packages = [ json-glib quarrel ];
    libname = "greet";
    authors = "Aylur";
    name = "AstalGreet";
    description = "IPC client for greetd";
  };

  hyprland = mkAstalPkg {
    pname = "astal-hyprland";
    src = "${astalSrc}/lib/hyprland";
    packages = [ json-glib ];
    libname = "hyprland";
    authors = "Aylur";
    name = "AstalHyprland";
    description = "IPC client for Hyprland";
  };

  mpris = mkAstalPkg {
    pname = "astal-mpris";
    src = "${astalSrc}/lib/mpris";
    packages = [ quarrel libsoup_3 gdk-pixbuf json-glib ];
    libname = "mpris";
    authors = "Aylur";
    name = "AstalMpris";
    description = "Control mpris players";
  };

  network = mkAstalPkg {
    pname = "astal-network";
    src = "${astalSrc}/lib/network";
    packages = [ networkmanager ];
    libname = "network";
    authors = "Aylur";
    name = "AstalNetwork";
    description = "NetworkManager wrapper library";
    dependencies = [ "NM-1.0" ];
  };

  notifd = mkAstalPkg {
    pname = "astal-notifd";
    src = "${astalSrc}/lib/notifd";
    packages = [ quarrel json-glib gdk-pixbuf ];
    libname = "notifd";
    authors = "Aylur";
    name = "AstalNotifd";
    description = "Notification daemon";
  };

  powerprofiles = mkAstalPkg {
    pname = "astal-powerprofiles";
    src = "${astalSrc}/lib/powerprofiles";
    packages = [ json-glib ];
    libname = "powerprofiles";
    authors = "Aylur";
    name = "AstalPowerProfiles";
    description = "DBus proxy for upowerd profiles";
  };

  river = mkAstalPkg {
    pname = "astal-river";
    src = "${astalSrc}/lib/river";
    packages = [ wl wl-vapi-gen ];
    libname = "river";
    authors = "kotontrion";
    name = "AstalRiver";
    description = "IPC client for River";
    dependencies = [ "AstalWl-0.1" ];
  };

  tray = mkAstalPkg {
    pname = "astal-tray";
    src = "${astalSrc}/lib/tray";
    packages = [ json-glib appmenu-glib-translator ];
    libname = "tray";
    authors = "kotontrion";
    name = "AstalTray";
    description = "StatusNotifierItem implementation";
  };

  wireplumber = mkAstalPkg {
    pname = "astal-wireplumber";
    src = "${astalSrc}/lib/wireplumber";
    packages = [ nix-wireplumber ];
    libname = "wireplumber";
    authors = "kotontrion";
    name = "AstalWp";
    description = "Wrapper library over the wireplumber API";
    dependencies = [ "WP-0.5" ];
  };

  wl = mkAstalPkg {
    pname = "astal-wl";
    src = "${astalSrc}/lib/wl";
    packages = [ wl-vapi-gen ];
    libname = "wl";
    authors = "kotontrion";
    name = "AstalWl";
    description = "A central wayland connection manager for the other libs.";
  };

  default = io;
}
