project(
  'cassette',
  'vala',
  version: '0.3.rc',
  meson_version: '>= 1.5.0',
  license: 'GPL-3.0-or-later',
)

soversion = '0'
lib_version = soversion + '.' + meson.project_version().replace('.rc', '')

i18n = import('i18n')
gnome = import('gnome')
py = import('python')
pkgconfig = import('pkgconfig')
cc = meson.get_compiler('c')

pascal_name = 'Cassette'
app_id = 'space.rirusha.Cassette'

nightly = false

libadwaita_dep = dependency('libadwaita-1', version: '>= 1.6')

add_project_arguments(
  '-w',
  language: ['c'],
)

name_suffix = ''
version_suffix = ''
app_id_suffix = ''



if get_option('nightly')
  git = find_program('git', required: false)
  hash = ''

  if git.found()
    hash = run_command(git.full_path(), 'rev-parse', '--short', 'HEAD', check: true).stdout().strip()
  endif

  nightly = true
  version_suffix = '.nightly'
  if hash != ''
    version_suffix += '.' + hash
  endif
  name_suffix = ' (Devel)'
  app_id_suffix = '.Devel'
endif

version = meson.project_version() + version_suffix

app_id_relevant = app_id + app_id_suffix
app_name = 'Cassette' + name_suffix

homepage = 'https://altlinux.space/rirusha/Cassette'
bugtracker = 'https://altlinux.space/rirusha/Cassette/issues'
# matrix.to banned in Russia so we use our matrix-to
help = 'https://alt-gnome.altlinux.team/matrix-to/#/#cassette-discussion:altlinux.org'

subdir('data')
subdir('po')
subdir('src')

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true,
)
