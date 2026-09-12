app_id = 'space.rirusha.Cassette'

name_suffix = ''
version_suffix = ''
app_id_suffix = ''

nightly = false

if meson.project_version().endswith('.rc') and not get_option('force-release')
  git = find_program('git', required: false)
  hash = ''

  if git.found()
    hash = run_command(git.full_path(), 'rev-parse', '--short', 'HEAD', check: true).stdout().strip()
  endif

  nightly = true
  if not meson.project_version().endswith('.rc')
    version_suffix = '.nightly'
  endif
  if hash != ''
    version_suffix += '.' + hash
  endif
  name_suffix = ' (Devel)'
  app_id_suffix = '.Devel'
endif

version = meson.project_version() + version_suffix
app_id_relevant = app_id + app_id_suffix
app_name = 'Cassette' + name_suffix

libadwaita_dep = dependency('libadwaita-1', version: '>= 1.6')
libcase_dep = dependency('libcase-0', fallback : ['libcase', 'lib_dep'])

subdir('data')
subdir('po')
subdir('src')

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true,
)
