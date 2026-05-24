project(
  'cassette',
  ['c', 'vala'],
  version: '0.2.4',
  meson_version: '>= 1.0.0',
  license: 'GPL-3.0-or-later',
)

i18n = import('i18n')
gnome = import('gnome')

gtk = dependency('gtk4', version: '>= 4.15')
libadwaita = dependency('libadwaita-1', version: '>= 1.6')
threads = dependency('threads')
libsoup = dependency('libsoup-3.0')
gdkpixbuf = dependency('gdk-pixbuf-2.0')
jsonglib = dependency('json-glib-1.0')
sqlite3 = dependency('sqlite3')
gee = dependency('gee-0.8')
libxml = dependency('libxml-2.0')
gstreamer = dependency('gstreamer-1.0')
webkit = dependency('webkitgtk-6.0', required: get_option('with_webkit'))
gio = dependency('gio-2.0', version: '>= 2.72')

app_id = 'space.rirusha.Cassette'

name_suffix = ''
version_suffix = ''
app_id_suffix = ''

if get_option('is_devel')
  name_suffix = ' (Devel)'
  app_id_suffix = '.Devel'

  find_program('git', required: true)
  vcs_tag = run_command('git', 'rev-parse', '--short', 'HEAD', check: true).stdout().strip()
  version_suffix = '-dev.@0@'.format (vcs_tag)
endif

app_id_dyn = '@0@@1@'.format (app_id, app_id_suffix)
app_name = 'Cassette@0@'.format (name_suffix)

conf = configuration_data()
conf.set_quoted('APP_ID', app_id)
conf.set_quoted('APP_ID_DYN', app_id_dyn)
conf.set_quoted('APP_NAME', app_name)
conf.set_quoted('G_LOG_DOMAIN', app_id)
conf.set10('IS_DEVEL', get_option('is_devel'))
conf.set_quoted('VERSION', '@0@@1@'.format (meson.project_version(), version_suffix))
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
conf.set_quoted('GNOMELOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
conf.set_quoted('HOMEPAGE', 'https://altlinux.space/rirusha/Cassette')
conf.set_quoted('BUGTRACKER', 'https://altlinux.space/rirusha/Cassette/issues')
conf.set_quoted('HELP', 'https://t.me/CassetteGNOME_Discussion')

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
]

if not get_option('with_webkit') and host_machine.system() != 'darwin'
  error('with_webkit=false is only supported on macOS (native WKWebView is darwin-only)')
endif

if host_machine.system() == 'darwin'
  add_languages('objc', native: false)
endif

webkit_vala_args = []
if webkit.found()
  cassette_dependencies += webkit
  conf.set10('WITH_WEBKIT', true)
  webkit_vala_args = ['--define=WITH_WEBKIT']
else
  conf.set10('WITH_WEBKIT', false)
endif

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
