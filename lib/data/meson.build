lib_blueprints = custom_target(
  'blueprints',
  input: files(
    'ui/sheet-submenu.blp',
  ),
  output: '.',
  command: [
    find_program('blueprint-compiler'),
    'batch-compile',
    '@OUTPUT@',
    '@CURRENT_SOURCE_DIR@',
    '@INPUT@',
  ],
)

lib_resource_files = files('@0@.Lib.gresource.xml'.format(app_id))
lib_resources = gnome.compile_resources(
  'libcassette-resources',
  lib_resource_files,
  dependencies: lib_blueprints,
  c_name: 'libcassette'
)
