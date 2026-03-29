vapi_sources = files(
  'config.vapi',
)

vala_sources = files(
  'ui/account/account-button.vala',
  'ui/account/account-info-dialog.vala',

  'ui/about.vala',
  'ui/auth.vala',
  'ui/loadable.vala',
  'ui/main-content.vala',
  'ui/warning-dialog.vala',
  'ui/window.vala',

  'application.vala',
  'devel-action-group.vala',
  'enums.vala',
  'main.vala',
  'message.vala',
  'utils.vala',
)

if get_option('with_webkit')
  vala_sources += files('ui/webkit/webkit-auth.vala')
endif

sources = [
  vapi_sources,
  vala_sources,
  resources,
]

app_dependencies = [
  lib_dep_static,
  libadwaita_dep,
  dependency('gee-0.8'),
  dependency('libtape-0', fallback : ['libtape', 'lib_dep']),
]

if get_option('with_webkit')
  app_dependencies += dependency('webkitgtk-6.0')
endif

executable(
  meson.project_name(),
  sources,
  include_directories: config_h_dir,
  dependencies: app_dependencies,
  install: true,
)
