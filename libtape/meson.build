libtape_name = 'libtape'
lib_name = 'tape'
gir_name = 'Tape'

versioned_name = libtape_name + '-' + soversion
versioned_lib_name = lib_name + '-' + soversion
versioned_gir_name = gir_name + '-' + soversion

deps_name = versioned_name + '.deps'
header_name = versioned_name + '.h'
vapi_name = versioned_name + '.vapi'
gir_name = versioned_gir_name + '.gir'
typelib_name = versioned_gir_name + '.typelib'

deps_pkgs = [
  'gee-0.8',
  'gio-2.0',
  'gstreamer-app-1.0',
  'gstreamer-1.0',
  'libapi-base-7',
  'libxml-2.0',
  'sqlite3',
]

gee_dep = dependency('gee-0.8')
gio_dep = dependency('gio-2.0')
gstreamer_app_dep = dependency('gstreamer-app-1.0')
gstreamer_dep = dependency('gstreamer-1.0')
libapi_base_dep = dependency('libapi-base-7', version: '>= 7.10', fallback : ['libapi-base', 'api_base_lib_dep'])
libxml_dep = dependency('libxml-2.0')
sqlite3_dep = dependency('sqlite3')

add_project_arguments(
  '-DGETTEXT_PACKAGE="@0@"'.format(libtape_name),
  language: ['c'],
)

conf = configuration_data()
conf.set_quoted('LIBRARY_NAME', gir_name)
conf.set_quoted('GETTEXT_PACKAGE', libtape_name)
conf.set_quoted('DATADIR', get_option('prefix') / get_option('datadir'))
conf.set_quoted('GNOMELOCALEDIR', get_option('prefix') / get_option('localedir'))

subdir('po')
subdir('src')
subdir('tests')

if get_option('documentation')
  subdir('doc')
endif
