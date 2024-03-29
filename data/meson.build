desktop_file = i18n.merge_file(
  input: '@0@.desktop.in'.format(app_id),
  output: '@0@.desktop'.format(app_id),
  type: 'desktop',
  po_dir: '../po',
  install: true,
  install_dir: join_paths(get_option('datadir'), 'applications')
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils, args: [desktop_file])
endif

appstream_file = i18n.merge_file(
  input: 'io.github.Rirusha.Cassette.appdata.xml.in',
  output: 'io.github.Rirusha.Cassette.appdata.xml',
  po_dir: '../po',
  install: true,
  install_dir: join_paths(get_option('datadir'), 'appdata')
)

appstream_util = find_program('appstream-util', required: false)
if appstream_util.found()
  test('Validate appstream file', appstream_util, args: ['validate-relax', appstream_file])
endif

install_data('io.github.Rirusha.Cassette.gschema.xml',
  install_dir: join_paths(get_option('datadir'), 'glib-2.0/schemas')
)

compile_schemas = find_program('glib-compile-schemas', required: false)
if compile_schemas.found()
  test('Validate schema file',
  compile_schemas,
  args: ['--strict', '--dry-run', meson.current_source_dir()])
endif

blueprints = custom_target('blueprints',
  input: files(
    'ui/account_info_window.blp',
    'ui/player_bar.blp',
    'ui/volume_button.blp',
    'ui/main_window.blp',
    'ui/track_info_panel.blp',
    'ui/cover_image.blp',
    'ui/sidebar.blp',
    'ui/track_detailed.blp',
    'ui/track_default_content.blp'
  ),
  output: '.',
  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)

resource_files = files('io.github.Rirusha.Cassette.gresource.xml')
resources = gnome.compile_resources(
  'cassette-resources',
  resource_files,
  dependencies: blueprints,
  c_name: 'cassette'
)

subdir('icons')