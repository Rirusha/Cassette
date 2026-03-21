valadoc = find_program('valadoc')

pkgs = []
foreach deps_pkg : lib_deps_pkgs
  pkgs += '--pkg=' + deps_pkg
endforeach

valadoc_vala_dir = meson.project_name() + '-vala'
custom_target(
  'valadoc',
  command: [ valadoc ] + pkgs +
  [
    lib_sources,
    '--target-glib=' + glib_min_version,
    '--package-name=' + lib_versioned_name,
    '--package-version=' + meson.project_version(),
    '--verbose',
    '--force',
    '-o', meson.current_build_dir() / valadoc_vala_dir,
  ],
  build_by_default: true,
  input : lib_sources,
  output: valadoc_vala_dir,
  depends: librs,
)

valadoc_cdocs_dir = meson.project_name() + '-cdocs'
custom_target(
  'cdocs',
  command: [ valadoc ] + pkgs +
  [
    lib_sources,
    '--target-glib=' + glib_min_version,
    '--package-name=' + lib_versioned_name,
    '--package-version=' + meson.project_version(),
    '--verbose',
    '--force',
    '-o', meson.current_build_dir() / valadoc_cdocs_dir,
    '--doclet-arg=' + 'lib' / 'src' / lib_header_name,
    '--doclet=gtkdoc',
  ],
  build_by_default: true,
  output: valadoc_cdocs_dir,
  depends: librs,
)
