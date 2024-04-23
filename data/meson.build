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
    'ui/account-info-dialog.blp',
    'ui/action-card-custom.blp',
    'ui/action-card-station.blp',
    'ui/cache-indicator.blp',
    'ui/cover-image.blp',
    'ui/custom-button.blp',
    'ui/custom-menu-button.blp',
    'ui/devel-view.blp',
    'ui/header-bar.blp',
    'ui/headered-scrolled-window.blp',
    'ui/help-overlay.blp',
    'ui/main-view.blp',
    'ui/window.blp',
    'ui/menu-dialog.blp',
    'ui/player-bar.blp',
    'ui/primary-menu-button.blp',
    'ui/sidebar.blp',
    'ui/stations-view.blp',
    'ui/track-default-content.blp',
    'ui/track-info.blp',
    'ui/track-info-panel.blp',
    'ui/volume-button.blp',
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