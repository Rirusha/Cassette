project(
  'cassette',
  ['c', 'vala'],
  version: '0.2.1',
  meson_version: '>= 1.0.0',
  license: 'GPL-3.0-or-later',
)

i18n = import('i18n')
gnome = import('gnome')

glib_min_version = '2.76'

app_id = 'space.rirusha.Cassette'

add_project_arguments(
  # GCC14 COMPILE ERROR
  '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
  '-w',
  language: ['c'],
)

add_project_arguments(
  '--target-glib', glib_min_version,
  '--vapidir', meson.current_source_dir(),
  language: ['vala'],
)

name_suffix = ''
version_suffix = ''
app_id_suffix = ''

if get_option('is_devel')
  name_suffix = ' (Devel)'
  app_id_suffix = '.Devel'

  git = find_program('git', required: true)
  vcs_tag = run_command(git.full_path(), 'rev-parse', '--short', 'HEAD', check: true).stdout().strip()
  version_suffix = '-dev.' + vcs_tag
endif

app_id_relevant = app_id + app_id_suffix
app_name = 'Cassette' + name_suffix

conf = configuration_data()
conf.set_quoted('APP_ID', app_id)
conf.set_quoted('APP_ID_RELEVANT', app_id_relevant)
conf.set_quoted('APP_NAME', app_name)
conf.set_quoted('G_LOG_DOMAIN', app_id_relevant)
conf.set10('IS_DEVEL', get_option('is_devel'))
conf.set_quoted('VERSION', meson.project_version() + version_suffix)
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('DATADIR', get_option('prefix') / get_option('datadir'))
conf.set_quoted('GNOMELOCALEDIR', get_option('prefix') / get_option('localedir'))
conf.set_quoted('HOMEPAGE', 'https://gitlab.gnome.org/Rirusha/Cassette')
conf.set_quoted('BUGTRACKER', 'https://gitlab.gnome.org/Rirusha/Cassette/-/issues')
conf.set_quoted('HELP', 'https://t.me/CassetteGNOME_Discussion')

configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

gee_dep = dependency('gee-0.8')
gio_dep = dependency('gio-2.0', version: '>= ' + glib_min_version)
libadwaita_dep = dependency('libadwaita-1', version: '>= 1.6')
libtape_dep = dependency('libtape-0.2', fallback : ['libtape', 'lib_dep'])
webkit_dep = dependency('webkitgtk-6.0')

dependencies = [
  gee_dep,
  gio_dep,
  libadwaita_dep,
  libtape_dep,
  webkit_dep,
]

subdir('data')
subdir('po')
subdir('src')

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true,
)
