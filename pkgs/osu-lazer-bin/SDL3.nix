{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  cmake,
  wayland,
  wayland-scanner,
  wayland-protocols,
  libGL,
  libxkbcommon,
  libdrm,
  mesa,
  udev,
  pipewire,
  libpulseaudio,
  libdecor,
  dbus,
  ibus,
  libiconv,
  alsa-lib,
  ...
}:
stdenv.mkDerivation (final: {
  pname = "SDL3";
  version = "3.1.2";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL";
    rev = "prerelease-${final.version}";
    hash = "sha256-2X6o8kHsfOnltJmiUYJm8fvfQbGGn8wpQqmO9WxKN0I=";
  };

  nativeBuildInputs = [pkg-config cmake wayland wayland-scanner];

  dlopenPropagatedBuildInputs = [libGL];
  propagatedBuildInputs = final.dlopenPropagatedBuildInputs;

  dlopenBuildInputs = [
    pipewire
    wayland
    libxkbcommon
    libdrm
    mesa
    udev
    libpulseaudio
    libdecor
    dbus
    alsa-lib
  ];

  buildInputs = [libiconv ibus wayland-protocols] ++ final.dlopenBuildInputs;

  enableParallelBuilding = true;
  strictDeps = true;

  patches = [
    ./sdl3-install-dirs.patch
  ];

  postFixup = let
    rpath = lib.makeLibraryPath (final.dlopenPropagatedBuildInputs ++ final.dlopenBuildInputs);
  in
    lib.optionalString (stdenv.hostPlatform.extensions.sharedLibrary == ".so") ''
      for lib in $out/lib/*.so* ; do
        if ! [[ -L "$lib" ]]; then
          patchelf --set-rpath "$(patchelf --print-rpath $lib):${rpath}" "$lib"
        fi
      done
    '';
})
