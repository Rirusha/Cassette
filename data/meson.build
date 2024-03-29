desktop_file = i18n.merge_file(
  input: '@0@.desktop.in'.format(app_id_dyn),
  output: '@0@.desktop'.format(app_id_dyn),
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
  input: '@0@.appdata.xml.in'.format(app_id),
  output: '@0@.appdata.xml'.format(app_id),
  po_dir: '../po',
  install: true,
  install_dir: join_paths(get_option('datadir'), 'appdata')
)

appstream_util = find_program('appstream-util', required: false)
if appstream_util.found()
  test('Validate appstream file', appstream_util, args: ['validate-relax', appstream_file])
endif

install_data('@0@.gschema.xml'.format(app_id),
  install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)

compile_schemas = find_program('glib-compile-schemas', required: false)
if compile_schemas.found()
  test('Validate schema file',
  compile_schemas,
  args: ['--strict', '--dry-run', meson.current_source_dir()])
endif

blueprints = custom_target('blueprints',
  input: files(
    'ui/account_info_dialog.blp',
    'ui/player_bar.blp',
    'ui/volume_button.blp',
    'ui/main_window.blp',
    'ui/track_info_panel.blp',
    'ui/cover_image.blp',
    'ui/sidebar.blp',
    'ui/track_detailed.blp',
    'ui/track_default_content.blp',
    'ui/main_view.blp',
    'ui/devel_view.blp',
    'ui/stations_view.blp',
    'ui/action_card_custom.blp',
    'ui/action_card_station.blp',
    'ui/headered_scrolled_window.blp',
    'ui/primary_menu_button.blp',
    'ui/header_bar.blp',
    'ui/track_carousel.blp',
  ),
  output: '.',
  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)

resource_files = files('@0@.gresource.xml'.format(app_id))
resources = gnome.compile_resources(
  'cassette-resources',
  resource_files,
  dependencies: blueprints,
  c_name: 'cassette'
)

subdir('icons')