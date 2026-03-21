non_quoted_conf = configuration_data()
non_quoted_conf.set('APP_ID', app_id)
non_quoted_conf.set('APP_ID_RELEVANT', app_id_relevant)
non_quoted_conf.set('HOMEPAGE', 'https://gitlab.gnome.org/Rirusha/Cassette')
non_quoted_conf.set('BUGTRACKER', 'https://gitlab.gnome.org/Rirusha/Cassette/-/issues')
non_quoted_conf.set('HELP', 'https://t.me/CassetteGNOME_Discussion')

if get_option('is_devel')
  metades_suffix = '-devel'
else
  metades_suffix = ''
endif

desktop_file = i18n.merge_file(
  input: configure_file(
    input: 'desktop' + metades_suffix + '.in.in',
    output: 'desktop.in',
    configuration: non_quoted_conf),
  output: app_id_relevant + '.desktop',
  type: 'desktop',
  po_dir: meson.project_source_root() / 'po',
  install: true,
  install_dir: get_option('datadir') / 'applications'
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils, args: [desktop_file])
endif
 
appstream_file = i18n.merge_file(
  input: configure_file(
    input: 'metainfo' + metades_suffix + '.xml.in.in',
    output: 'app.metainfo.xml.in',
    configuration: non_quoted_conf),
  output: app_id_relevant + '.metainfo.xml',
  po_dir: meson.project_source_root() / 'po',
  install: true,
  install_dir: get_option('datadir') / 'metainfo'
)

appstreamcli = find_program('appstreamcli', required: false)
if appstreamcli.found()
  test('Validate appstream file', appstreamcli, args: ['validate', appstream_file])
endif

install_data('gschema.xml',
  install_dir: get_option('datadir') / 'glib-2.0' / 'schemas',
  rename: app_id_relevant + '.gschema.xml',
)

compile_schemas = find_program('glib-compile-schemas', required: false)
if compile_schemas.found()
  test('Validate schema file',
  compile_schemas,
  args: ['--strict', '--dry-run', meson.current_source_dir()])
endif

find_program('blueprint-compiler')

auto = custom_target('auto',
  command: [
    py.find_installation().full_path(), meson.project_source_root() / 'tools' / 'auto-data.py',
    '@OUTPUT@',
    '@SOURCE_ROOT@',
    '@BUILD_ROOT@',
    '@CURRENT_SOURCE_DIR@',
    app_id_relevant,
  ],
  build_always_stale: true,
  output: '.',
)

# Create an empty file gresource.xml to prevent meson from giving an error during the configuration stage
run_command(['touch', meson.current_build_dir() / 'gresource.xml'], check: true)
resources = gnome.compile_resources(
  'cassette-resources',
  meson.current_build_dir() / 'gresource.xml',
  source_dir: meson.current_build_dir(),
  dependencies: auto,
  c_name: 'cassette'
)

subdir('icons')
