vapi_sources = files(
  'config.vapi',
)

vala_sources = files(
  'client.vala',
  'enums.vala',
  'errors.vala',
  'result-codec.vala',
  'settings.vala',
  'utils.vala',
)

subdir('cache-manager')
subdir('heap')
subdir('player')
subdir('yandex-music')

sources = [
  vapi_sources,
  vala_sources,
]
libtape_test_sources = []
foreach group : sources
  foreach source : group
    if source.full_path().endswith('/yandex-music/utils.vala')
      libtape_test_sources += configure_file(
        input: source,
        output: 'test-yandex-utils.vala',
        copy: true,
      )
    else
      libtape_test_sources += source
    endif
  endforeach
endforeach

pgconfig_dependencies = [
  gee_dep,
  gio_dep,
  gstreamer_app_dep,
  gstreamer_dep,
  libxml_dep,
  libsecret_dep,
  sqlite3_dep,
]
dependencies = pgconfig_dependencies + [
  libdeser_dep,
  libsession_dep
]
libtape_test_dependencies = dependencies

if libdeser_dep.type_name() == 'pkgconfig'
  pgconfig_dependencies += libdeser_dep
endif

if libsession_dep.type_name() == 'pkgconfig'
  pgconfig_dependencies += libsession_dep
endif

configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')
libtape_test_config_h_dir = config_h_dir

lib_c_args = [
  '-DG_LOG_DOMAIN="@0@"'.format(libtape_name),
  '-DGETTEXT_PACKAGE="@0@"'.format(libtape_name)
]
libtape_test_c_args = lib_c_args

lib = library(
  versioned_lib_name,
  sources,
  dependencies: dependencies,
  include_directories: config_h_dir,
  vala_header: header_name,
  vala_vapi: vapi_name,
  vala_gir: gir_name,
  c_args: lib_c_args,
  vala_args: ['--vapi-comments', '--enable-experimental'],
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
  fs = import('fs')

  gir_includes = [
    '--includedir', gee_dep.get_variable('datadir') / 'gir-1.0',
  ]
  gir_dependencies = [lib]

  if libdeser_dep.type_name() == 'internal'
    deser_project = subproject('libdeser')

    deser_target = deser_project.get_variable('deser_lib')
    session_target = deser_project.get_variable('session_lib')

    gir_includes += [
      '--includedir', fs.parent(deser_target.vala_gir().full_path()),
      '--includedir', fs.parent(session_target.vala_gir().full_path()),
    ]

    gir_dependencies += [deser_target, session_target]
  endif

  custom_target(
    'typelib',
    command: [
      g_ir_compiler,
      '--shared-library', '@PLAINNAME@',
      '--output', '@OUTPUT@',
    ] + gir_includes + [
      meson.current_build_dir() / gir_name,
    ],
    input: lib,
    output: typelib_name,
    depends: gir_dependencies,
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
