project(
  'cassette',
  'vala',
  version: '0.2',
  meson_version: '>= 1.1.0',
  license: 'GPL-3.0-or-later',
)

api_version = '0'
lib_version = api_version + '.' + meson.project_version()

i18n = import('i18n')
gnome = import('gnome')
py = import('python')
pkgconfig = import('pkgconfig')

pascal_name = 'Cassette'
app_id = 'space.rirusha.Cassette'

libadwaita_dep = dependency('libadwaita-1', version: '>= 1.6')

add_project_arguments(
  '-w',
  language: ['c'],
)

add_project_arguments(
  '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
  language: ['c']
)
name_suffix = ''
version_suffix = ''
app_id_suffix = ''

if get_option('is_devel')
  name_suffix = ' (Devel)'
  app_id_suffix = '.Devel'

  git = find_program('git', required: true)
  n_commits = run_command(meson.current_source_dir() + '/tools/get-n-commits', meson.project_version(), check: true).stdout().strip()
  version_suffix = '.nightly.' + n_commits
endif

if not get_option('lib_only')

  version = meson.project_version() + version_suffix

  app_id_relevant = app_id + app_id_suffix
  app_name = 'Cassette' + name_suffix

  homepage = 'https://gitlab.gnome.org/Rirusha/Cassette'
  bugtracker = 'https://gitlab.gnome.org/Rirusha/Cassette/-/issues'
  # matrix.to banned in Russian so we use our matrix-to
  help = 'https://alt-gnome.altlinux.team/matrix-to/#/#cassette-discussion:altlinux.org'
endif

subdir('lib')

if not get_option('lib_only')
  subdir('data')
  subdir('po')
  subdir('src')

  gnome.post_install(
    glib_compile_schemas: true,
    gtk_update_icon_cache: true,
    update_desktop_database: true,
  )
endif
