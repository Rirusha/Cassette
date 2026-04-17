conf = configuration_data()
conf.set_quoted('G_LOG_DOMAIN', 'Cassette')
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('DATADIR', get_option('datadir'))
conf.set_quoted('GNOMELOCALEDIR',  get_option('localedir'))

configure_file(output: 'config.h', configuration: conf)

lib_name = 'lib' + meson.project_name()
lib_gir_name = pascal_name

lib_versioned_name = lib_name + '-' + api_version
lib_versioned_lib_name = lib_name + '-' + api_version
lib_versioned_gir_name = lib_gir_name + '-' + api_version

lib_deps_name = lib_versioned_lib_name + '.deps'
lib_header_name = lib_versioned_lib_name + '.h'
lib_vapi_name = lib_versioned_lib_name + '.vapi'
lib_gir_name = lib_versioned_gir_name + '.gir'
lib_typelib_name = lib_versioned_gir_name + '.typelib'

lib_deps_pkgs = [
  'libadwaita-1',
]

lib_vapi_sources = files(
  'config.vapi',
)

lib_vapi_sources += configure_file(
  input: 'resources.vapi.in',
  output: 'resources.vapi',
  configuration: {
    'RESOURCES_HEADER': resources_header,
  },
)

lib_vala_sources = files(
  'combo-row/combo-row.vala',
  'combo-row/default-row-content.vala',

  'menu-button/menu/buildable.vala',
  'menu-button/menu/item.vala',
  'menu-button/menu/menu.vala',
  'menu-button/menu/section.vala',
  'menu-button/menu/submenu.vala',

  'menu-button/popover/menu-item.vala',
  'menu-button/popover/menu.vala',
  'menu-button/popover/page.vala',
  'menu-button/popover/section.vala',

  'menu-button/sheet/action-tracker.vala',
  'menu-button/sheet/menu-item.vala',
  'menu-button/sheet/menu.vala',
  'menu-button/sheet/page.vala',
  'menu-button/sheet/section.vala',

  'menu-button/indicator-bin.vala',
  'menu-button/menu-button.vala',

  'badge.vala',
  'enums.vala',
  'gizmo.vala',
  'init.vala',
  'utils.vala',
)

lib_sources = [
  lib_vapi_sources,
  lib_vala_sources,
]

lib_sources_with_resources = lib_sources + [lib_resources]

lib_dependencies = [
  libadwaita_dep,
]

lib_deps_pkgs = []
foreach dep : lib_dependencies
  lib_deps_pkgs += [dep.name()]
endforeach

if get_option('static')
  libcassette_static = static_library(
    lib_name,
    lib_sources_with_resources,
    dependencies: lib_dependencies,
  )

  lib_dep_static = declare_dependency(
    link_with: libcassette_static,
    include_directories: include_directories('.'),
    dependencies: lib_dependencies
  )
endif

libcassette = library(
  meson.project_name() + '-' + api_version,
  lib_sources_with_resources,
  dependencies: lib_dependencies,
  vala_header: lib_header_name,
  vala_vapi: lib_vapi_name,
  vala_gir: lib_gir_name,
  include_directories: include_directories('.'),
  version: lib_version,
  soversion: lib_version,
  install: not get_option('static'),
  install_dir: [ true, true, true, true ],
)

lib_dep = declare_dependency(
  link_with: libcassette,
  include_directories: include_directories('.'),
  dependencies: lib_dependencies
)

deps_conf = configuration_data()
deps_conf.set ('DEPS',  '\n'.join (lib_deps_pkgs))

configure_file(
  input: 'lib.deps.in',
  output: lib_deps_name,
  configuration: deps_conf,
  install: not get_option('static'),
  install_dir: get_option('datadir') / 'vala' / 'vapi',
)

if not get_option('lib_only') or get_option('with_lib_introspection')
  g_ir_compiler = find_program('g-ir-compiler')
  lib_gir = custom_target(
    'typelib',
    command: [
      g_ir_compiler,
      '--shared-library', '@PLAINNAME@',
      '--output', '@OUTPUT@',
      meson.current_build_dir() / lib_gir_name,
    ],
    input: libcassette,
    output: lib_typelib_name,
    depends: libcassette,
    install: not get_option('static'),
    install_dir: get_option('libdir') / 'girepository-1.0',
  )
endif

if not get_option('static')
  pkgconfig.generate(
    libcassette,
    name: lib_versioned_lib_name,
    requires: lib_dependencies,
    subdirs: [ lib_versioned_name ],
    description: 'Library of useful Cassette widgets',
    version: lib_version,
    url: 'https://gitlab.gnome.org/Rirusha/Cassette',
  )
endif
