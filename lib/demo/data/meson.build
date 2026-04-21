non_quoted_conf = configuration_data()
non_quoted_conf.set('APP_ID', demo_app_id)
non_quoted_conf.set('APP_ID_RELEVANT', demo_app_id_relevant)
non_quoted_conf.set('HOMEPAGE', homepage)
non_quoted_conf.set('BUGTRACKER', bugtracker)
non_quoted_conf.set('HELP', help)

if is_devel
  metades_suffix = '-devel'
  non_quoted_conf.set('DATE', run_command('date', '+%Y-%m-%d', check: true).stdout().strip())
  non_quoted_conf.set('USER', run_command('whoami', check: true).stdout().strip())
  non_quoted_conf.set('VERSION', version)
else
  metades_suffix = ''
endif

desktop_file = i18n.merge_file(
  input: configure_file(
    input: 'desktop' + metades_suffix + '.in.in',
    output: 'desktop.in',
    configuration: non_quoted_conf),
  output: demo_app_id_relevant + '.desktop',
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
    input: 'metainfo.xml.in.in',
    output: 'app.metainfo.xml.in',
    configuration: non_quoted_conf),
  output: demo_app_id_relevant + '.metainfo.xml',
  po_dir: meson.project_source_root() / 'po',
  install: true,
  install_dir: get_option('datadir') / 'metainfo'
)

appstreamcli = find_program('appstreamcli', required: false)
if appstreamcli.found()
  test('Validate appstream file', appstreamcli, args: ['validate', appstream_file])
endif

find_program('blueprint-compiler')

blueprints_demo = custom_target(
  'blueprints',
  input: files(
    'ui/window.blp',
  ),
  output: '.',
  depends: lib_gir,
  build_always_stale: true,
  command: [
    find_program('blueprint-compiler'),
    'batch-compile',
    '--gir-path', meson.current_build_dir() / '../../src',
    '--typelib-path', meson.current_build_dir() / '../../src',
    '@OUTPUT@',
    '@CURRENT_SOURCE_DIR@',
    '@INPUT@',
  ],
)

res_file = configure_file(
  input: 'gresource.xml.in',
  output: 'gresource.xml',
  configuration: non_quoted_conf,
)

resources_demo = gnome.compile_resources(
  'libcassette-resources',
  res_file,
  dependencies: blueprints_demo,
  c_name: 'cassette_demo',
)

subdir('icons')
