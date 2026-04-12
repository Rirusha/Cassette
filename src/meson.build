
conf = configuration_data()
conf.set_quoted('APP_ID', app_id)
conf.set_quoted('APP_ID_RELEVANT', app_id_relevant)
conf.set_quoted('APP_NAME', app_name)
conf.set_quoted('G_LOG_DOMAIN', app_id_relevant)
conf.set10('IS_DEVEL', get_option('is_devel'))
conf.set_quoted('VERSION', version)
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('DATADIR', get_option('prefix') / get_option('datadir'))
conf.set_quoted('GNOMELOCALEDIR', get_option('prefix') / get_option('localedir'))
conf.set_quoted('HOMEPAGE', homepage)
conf.set_quoted('BUGTRACKER', bugtracker)
conf.set_quoted('HELP', help)

configure_file(output: 'config.h', configuration: conf)

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

vala_args = []

if get_option('with_webkit')
  vala_sources += files('ui/webkit/webkit-auth.vala')
  vala_args += '--define=WITH_WEBKIT'
endif

sources = [
  vapi_sources,
  vala_sources,
  resources,
]

app_dependencies = [
  libadwaita_dep,
  dependency('gee-0.8'),
  dependency('libtape-0', fallback : ['libtape', 'lib_dep']),
]

if get_option('static')
  app_dependencies += lib_dep_static
else 
  app_dependencies += lib_dep
endif

if get_option('with_webkit')
  app_dependencies += dependency('webkitgtk-6.0')
endif

executable(
  meson.project_name(),
  sources,
  vala_args: vala_args,
  include_directories: include_directories('.'),
  dependencies: app_dependencies,
  install: true,
)
