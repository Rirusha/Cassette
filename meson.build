project(
  'cassette',
  'vala',
  version: '0.2',
  meson_version: '>= 1.5.0',
  license: 'GPL-3.0-or-later',
)

api_version = '0'
lib_version = api_version + '.' + meson.project_version()

i18n = import('i18n')
gnome = import('gnome')
py = import('python')
pkgconfig = import('pkgconfig')
cc = meson.get_compiler('c')

pascal_name = 'Cassette'
demo_app_id = 'space.rirusha.CassetteDemo'
app_id = 'space.rirusha.Cassette'

is_devel = false

libadwaita_dep = dependency('libadwaita-1', version: '>= 1.6')

add_project_arguments(
  '-w',
  language: ['c'],
)

name_suffix = ''
version_suffix = ''
app_id_suffix = ''

git = find_program('git', required: false)
if git.found()
  n_commits = run_command(meson.current_source_dir() + '/tools/get-n-commits', meson.project_version(), check: true).stdout().strip()
else
  n_commits = '0'
endif

if n_commits != '0' or n_commits == ''
  is_devel = true
  version_suffix = '.nightly'
  if n_commits != ''
    version_suffix += '.' + n_commits
  endif
  name_suffix = ' (Devel)'
  app_id_suffix = '.Devel'
endif

version = meson.project_version() + version_suffix

demo_app_id_relevant = demo_app_id
demo_app_name = 'Cassette Demo'

app_id_relevant = app_id + app_id_suffix
app_name = 'Cassette' + name_suffix

homepage = 'https://altlinux.space/rirusha/Cassette'
bugtracker = 'https://altlinux.space/rirusha/Cassette/issues'
# matrix.to banned in Russia so we use our matrix-to
help = 'https://alt-gnome.altlinux.team/matrix-to/#/#cassette-discussion:altlinux.org'

subdir('lib')

if not get_option('lib_only')
  subdir('data')
  subdir('po')
  subdir('src')
endif

gnome.post_install(
  glib_compile_schemas: not get_option('lib_only'),
  gtk_update_icon_cache: (not get_option('lib_only')) or get_option('install_demo'),
  update_desktop_database: (not get_option('lib_only')) or get_option('install_demo'),
)
