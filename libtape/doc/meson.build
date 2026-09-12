valadoc = find_program('valadoc')

pkgs = []
foreach deps_pkg : deps_pkgs
  pkgs += '--pkg=' + deps_pkg
endforeach

valadoc_vala_dir = libtape_name + '-vala'
custom_target(
  'valadoc',
  command: [ valadoc ] + pkgs +
  [
    sources,
    '--package-name=' + versioned_name,
    '--package-version=' + libversion,
    '--verbose',
    '--force',
    '-o', meson.current_build_dir() / valadoc_vala_dir,
  ],

  build_by_default: true,
  input : sources,
  output: valadoc_vala_dir,
  depends: lib,
)
