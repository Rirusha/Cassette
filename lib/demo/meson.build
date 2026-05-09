subdir('data')

conf = configuration_data()
conf.set_quoted('APP_ID', demo_app_id)
conf.set_quoted('APP_ID_RELEVANT', demo_app_id_relevant)
conf.set_quoted('APP_NAME', demo_app_name)
conf.set_quoted('G_LOG_DOMAIN', demo_app_id_relevant)
conf.set10('NIGHTLY', nightly)
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
  'application.vala',
  'main.vala',
  'window.vala',
)

c_args = [
  '-DGETTEXT_PACKAGE="@0@"'.format(lib_name),
]

vala_args = []

sources = [
  vapi_sources,
  vala_sources,
  resources_demo,
]

app_dependencies = [
  lib_dep_static
]

executable(
  lib_name + '-demo',
  sources,
  vala_args: vala_args,
  c_args: c_args,
  include_directories: include_directories('.'),
  dependencies: app_dependencies,
  install: get_option('install_demo'),
)
