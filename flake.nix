{
  description = "GTK4/Adwaita application that allows you to use Yandex Music service on Linux operating systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {inherit system;};

        nativeBuildInputs = with pkgs; [
          blueprint-compiler
          desktop-file-utils
          meson
          ninja
          pkg-config
          vala
        ];

        buildInputs = with pkgs; [
          glib-networking
          gst_all_1.gst-plugins-bad
          gst_all_1.gst-plugins-base
          gst_all_1.gst-plugins-good
          gst_all_1.gstreamer
          gtk4
          json-glib
          libadwaita
          libgee
          libsoup_3
          libxml2
          sqlite
          webkitgtk_6_0
        ];
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "cassette";
          src = self;

          mesonFlags = [
            "-Dis_devel=true"
          ];

          nativeBuildInputs = with pkgs;
            [
              wrapGAppsHook4
              git
            ]
            ++ nativeBuildInputs;

          inherit buildInputs;

          strictDeps = true;
        };
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [alejandra] ++ nativeBuildInputs ++ buildInputs;
        };
      }
    );
}
