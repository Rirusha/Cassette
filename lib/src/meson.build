lib_name = 'lib' + meson.project_name()
lib_gir_name = pascal_name

lib_versioned_name = meson.project_name() + '-' + api_version
lib_versioned_lib_name = lib_name + '-' + api_version
lib_versioned_gir_name = lib_gir_name + '-' + api_version

lib_deps_name = lib_versioned_lib_name + '.deps'
lib_header_name = lib_versioned_lib_name + '.h'
lib_vapi_name = lib_versioned_lib_name + '.vapi'
lib_gir_name = lib_versioned_gir_name + '.gir'
lib_typelib_name = lib_versioned_gir_name + '.typelib'

lib_vapi_sources = files(

)

lib_vala_sources = files(
  'menu-button.vala',
)

lib_sources = [
  lib_vapi_sources,
  lib_vala_sources,
]

lib_sources_with_resources = lib_sources + [lib_resources]

lib_c_args = [
  '-DGETTEXT_PACKAGE="@0@"'.format(lib_name),
  '-w',
]

rs_app_vala_args = [
  '--vapidir', meson.project_source_root() / 'vapi',
]

lib_dependencies = [
  libadwaita_dep,
]

lib_deps_pkgs = []
foreach dep : lib_dependencies
  lib_deps_pkgs += [dep.name()]
endforeach

librs = library(
  lib_versioned_name,
  lib_sources_with_resources,
  dependencies: lib_dependencies,
  vala_header: lib_header_name,
  vala_vapi: lib_vapi_name,
  vala_gir: lib_gir_name,
  version: meson.project_version(),
  soversion: meson.project_version(),
  install: true,
  install_dir: [ true, true, true, true ],
  c_args: lib_c_args,
  vala_args: rs_app_vala_args,
)

lib_dep = declare_dependency(
  link_with: librs,
  include_directories: include_directories('.'),
  dependencies: lib_dependencies
)

deps_conf = configuration_data()
deps_conf.set ('DEPS',  '\n'.join (lib_deps_pkgs))

configure_file(
  input: 'lib.deps.in',
  output: lib_deps_name,
  configuration: deps_conf,
  install: true,
  install_dir: get_option('datadir') / 'vala' / 'vapi',
)

if get_option('with_lib_introspection')
  g_ir_compiler = find_program('g-ir-compiler')
  custom_target(
    'typelib',
    command: [
      g_ir_compiler,
      '--shared-library', '@PLAINNAME@',
      '--output', '@OUTPUT@',
      meson.current_build_dir() / lib_gir_name,
    ],
    input: librs,
    output: lib_typelib_name,
    depends: librs,
    install: true,
    install_dir: get_option('libdir') / 'girepository-1.0',
  )
endif

pkgconfig.generate(
  librs,
  name: lib_versioned_lib_name,
  requires: lib_dependencies,
  subdirs: [ lib_versioned_name ],
  description: 'ReadySet library',
  version: meson.project_version(),
  url: 'https://altlinux.space/alt-gnome/ReadySet',
)
