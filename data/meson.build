desktop_conf = configuration_data()
desktop_conf.set('APP_ID_DYN', app_id_dyn)

desktop_file = i18n.merge_file(
  input: configure_file(
    output: '@0@.desktop.in'.format(app_id_dyn),
    input: '@0@.desktop.in.in'.format(app_id_dyn),
    configuration: desktop_conf),
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

appstream_conf = configuration_data()
appstream_conf.set('APP_ID', app_id)
appstream_conf.set('APP_ID_DYN', app_id_dyn)
appstream_conf.set('HOMEPAGE', 'https://gitlab.gnome.org/Rirusha/Cassette')
appstream_conf.set('BUGTRACKER', 'https://gitlab.gnome.org/Rirusha/Cassette/-/issues')
appstream_conf.set('HELP', 'https://t.me/CassetteGNOME_Discussion')

appstream_file = i18n.merge_file(
  input: configure_file(
    output: '@0@.metainfo.xml.in'.format(app_id),
    input: '@0@.metainfo.xml.in.in'.format(app_id),
    configuration: appstream_conf),
  output: '@0@.metainfo.xml'.format(app_id),
  po_dir: '../po',
  install: true,
  install_dir: join_paths(get_option('datadir'), 'metainfo')
)

appstreamcli = find_program('appstreamcli', required: false)
if appstreamcli.found()
  test('Validate appstream file', appstreamcli, args: ['validate', appstream_file])
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
    'ui/equalaizer.blp',
    'ui/header-bar.blp',
    'ui/headered-scrolled-window.blp',
    'ui/help-overlay.blp',
    'ui/loadable-widget.blp',
    'ui/main-view.blp',
    'ui/menu-dialog.blp',
    'ui/narrow-toggle-button.blp',
    'ui/no-plus-dialog.blp',
    'ui/player-bar.blp',
    'ui/player-queue.blp',
    'ui/sidebar.blp',
    'ui/stations-view.blp',
    'ui/track-base-content.blp',
    'ui/track-carousel.blp',
    'ui/track-queue-content.blp',
    'ui/track-default-content.blp',
    'ui/track-info.blp',
    'ui/track-info-panel.blp',
    'ui/volume-button.blp',
    'ui/wave-settings.blp',
    'ui/window.blp',
  ),
  output: '.',
  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)

resource_files = files('@0@.gresource.xml'.format(app_id))
resources = gnome.compile_resources(
  'cassette-resources',
  resource_files,
  source_dir: meson.current_build_dir(),
  dependencies: blueprints,
  c_name: 'cassette'
)

subdir('icons')
