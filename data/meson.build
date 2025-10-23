non_quoted_conf = configuration_data()
non_quoted_conf.set('APP_ID', app_id)
non_quoted_conf.set('APP_ID_RELEVANT', app_id_relevant)
non_quoted_conf.set('HOMEPAGE', 'https://gitlab.gnome.org/Rirusha/Cassette')
non_quoted_conf.set('BUGTRACKER', 'https://gitlab.gnome.org/Rirusha/Cassette/-/issues')
non_quoted_conf.set('HELP', 'https://t.me/CassetteGNOME_Discussion')

desktop_file = i18n.merge_file(
  input: configure_file(
    output: app_id_relevant + '.desktop.in',
    input: app_id_relevant + '.desktop.in.in',
    configuration: non_quoted_conf),
  output: app_id_relevant + '.desktop',
  type: 'desktop',
  po_dir: '../po',
  install: true,
  install_dir: get_option('datadir') / 'applications'
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils, args: [desktop_file])
endif

appstream_file = i18n.merge_file(
  input: configure_file(
    output: app_id + '.metainfo.xml.in',
    input: app_id + '.metainfo.xml.in.in',
    configuration: non_quoted_conf),
  output: app_id + '.metainfo.xml',
  po_dir: '../po',
  install: true,
  install_dir: get_option('datadir') / 'metainfo'
)

appstreamcli = find_program('appstreamcli', required: false)
if appstreamcli.found()
  test('Validate appstream file', appstreamcli, args: ['validate', appstream_file])
endif

install_data(app_id + '.gschema.xml',
  install_dir: get_option('datadir') / 'glib-2.0' / 'schemas'
)

compile_schemas = find_program('glib-compile-schemas', required: false)
if compile_schemas.found()
  test('Validate schema file',
  compile_schemas,
  args: ['--strict', '--dry-run', meson.current_source_dir()])
endif

blueprints = custom_target('blueprints',
  input: files(
    'ui/window.blp',
  ),
  output: '.',
  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)

resource_files = files(app_id + '.gresource.xml')
resources = gnome.compile_resources(
  'cassette-resources',
  resource_files,
  source_dir: meson.current_build_dir(),
  dependencies: blueprints,
  c_name: 'cassette'
)

subdir('icons')
