project(
  'cassette',
  ['c', 'vala'],
  version: '0.2.0',
  meson_version: '>= 0.62.0',
  license: 'GPL-3.0-only',
)

i18n = import('i18n')
gnome = import('gnome')

gtk = dependency('gtk4', version: '>= 4.14')
libadwaita = dependency('libadwaita-1', version: '>= 1.5')
threads = dependency('threads')
libsoup = dependency('libsoup-3.0')
gdkpixbuf = dependency('gdk-pixbuf-2.0')
jsonglib = dependency('json-glib-1.0')
sqlite3 = dependency('sqlite3')
gee = dependency('gee-0.8')
libxml = dependency('libxml-2.0')
gstreamer = dependency('gstreamer-1.0')
webkit = dependency('webkitgtk-6.0')
gio = dependency('gio-2.0', version: '>= 2.72')

app_id = 'io.github.Rirusha.Cassette'

if get_option('profile') == 'development'
  find_program('git', required: true)
  name_postfix = ' (Devel)'
  app_id_dyn = '@0@-Devel'.format(app_id)
  app_identity_dyn = 'Cassette (Devel)'
  profile = 'Devel'
  vcs_tag = run_command('git', 'rev-parse', '--short', 'HEAD').stdout().strip()
  version_suffix = '-dev.@0@'.format (vcs_tag)
else
  name_postfix = ''
  app_id_dyn = app_id
  app_identity_dyn = 'Cassette'
  profile = ''
  version_suffix = ''
endif

conf = configuration_data()
conf.set_quoted('APP_ID', app_id)
conf.set_quoted('APP_NAME', 'Cassette@0@'.format (name_postfix))
conf.set_quoted('APP_ID_DYN', app_id_dyn)
conf.set_quoted('APP_IDENTITY_DYN', app_identity_dyn)
conf.set_quoted('G_LOG_DOMAIN', app_id)
conf.set_quoted('PROFILE', profile)
conf.set_quoted('VERSION', meson.project_version() + version_suffix)
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
conf.set_quoted('GNOMELOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))

subdir('data')

cassette_dependencies = [
  gtk,
  libadwaita,
  threads,
  libsoup,
  gdkpixbuf,
  jsonglib,
  sqlite3,
  gee,
  libxml,
  gstreamer,
  gio,
  webkit
]

configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

subdir('po')
subdir('src')
subdir('tests')

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true,
)