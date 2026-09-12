vapi_sources = files(
  'config.vapi',
)

vala_sources = files(
  'client.vala',
  'enums.vala',
  'errors.vala',
  'hash-store.vala',
  'settings.vala',
  'utils.vala',
  'yandex-music.vala',
)

subdir('cache-manager')
subdir('model-manager')
subdir('player')
subdir('yandex-music')

sources = [
  vapi_sources,
  vala_sources,
]

pgconfig_dependencies = [
  gee_dep,
  gio_dep,
  gstreamer_app_dep,
  gstreamer_dep,
  libxml_dep,
  sqlite3_dep,
]
dependencies = pgconfig_dependencies + [
  libapi_base_dep
]

if libapi_base_dep.type_name() == 'pkgconfig'
  pgconfig_dependencies += libapi_base_dep
endif

configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

lib_c_args = [
  '-DG_LOG_DOMAIN="@0@"'.format(libtape_name),
  '-DGETTEXT_PACKAGE="@0@"'.format(libtape_name)
]

lib = library(
  versioned_lib_name,
  sources,
  dependencies: dependencies,
  include_directories: config_h_dir,
  vala_header: header_name,
  vala_vapi: vapi_name,
  vala_gir: gir_name,
  c_args: lib_c_args,
  vala_args: ['--vapi-comments'],
  link_args: ['-lm'],
  version: libversion,
  soversion: soversion,
  install: true,
  install_vala_header: true,
  install_vala_vapi: true,
  install_vala_gir: true,
)

lib_dep = declare_dependency(
  link_with: lib,
  include_directories: include_directories('.'),
  dependencies: dependencies
)

deps_conf = configuration_data()
deps_conf.set ('DEPS',  '\n'.join (deps_pkgs))

configure_file(
  input: 'lib.deps.in',
  output: deps_name,
  configuration: deps_conf,
  install: true,
  install_dir: get_option('datadir') / 'vala' / 'vapi',
)

if get_option('introspection')
  g_ir_compiler = find_program('g-ir-compiler')
  custom_target(
    'typelib',
    command: [
      g_ir_compiler,
      '--shared-library', '@PLAINNAME@',
      '--output', '@OUTPUT@',
      '--includedir', gee_dep.get_variable('datadir') / 'gir-1.0',
      meson.current_build_dir() / gir_name,
    ],
    input: lib,
    output: typelib_name,
    depends: lib,
    install: true,
    install_dir: get_option('libdir') / 'girepository-1.0',
  )
endif

pkgconfig.generate(
  lib,
  name: versioned_name,
  requires: pgconfig_dependencies,
  subdirs: [ versioned_name ],
  description: 'Unofficial Yandex Music client library',
  version: libversion,
  url: homepage,
)
