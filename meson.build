project(
  'cassette',
  ['c', 'vala'],
  version: '0.1',
  meson_version: '>= 0.62.0',
  license: 'GPL-3.0-or-later',
)

i18n = import('i18n')
gnome = import('gnome')

gtk = dependency('gtk4', version: '>= 4.5')
libadwaita = dependency('libadwaita-1', version: '>= 1.4')
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

if get_option('profile') == 'development'
  name_prefix = '(Development) '
  postfix = '.Devel'
else
  name_prefix = ''
  postfix = ''
endif

app_id = 'io.github.Rirusha.Cassette@0@'.format(postfix)

conf = configuration_data()
conf.set_quoted('APP_ID', app_id)
conf.set_quoted('G_LOG_DOMAIN', app_id)
conf.set_quoted('NAME_PREFIX', name_prefix)
conf.set_quoted('PACKAGE_NAME', meson.project_name())
conf.set_quoted('PACKAGE_VERSION', meson.project_version())
conf.set_quoted('POSTFIX', postfix)
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
conf.set_quoted('GNOMELOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))

configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

subdir('po')
subdir('data')
subdir('src')
subdir('tests')

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true,
)