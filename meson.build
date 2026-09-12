project(
  'cassette',
  'vala',
  version: '0.5.0.rc',
  meson_version: '>= 1.11.0',
  license: 'GPL-3.0-or-later',
)

libversion = meson.project_version().replace('.rc', '')
version_parts = libversion.split('.')
if version_parts[0] == '0'
  soversion = version_parts[0] + '.' + version_parts[1]
else
  soversion = version_parts[0]
endif

i18n = import('i18n')
gnome = import('gnome')
py = import('python')
pkgconfig = import('pkgconfig')
cc = meson.get_compiler('c')

add_project_arguments(
  '-w',
  language: ['c'],
)

add_project_arguments(
  '--abi-stability',
  '--hide-internal',
  '--vapidir', meson.current_source_dir(),
  language: ['vala'],
)

homepage = 'https://altlinux.space/rirusha/Cassette'
bugtracker = 'https://altlinux.space/rirusha/Cassette/issues'
# matrix.to banned in Russia so we use our matrix-to
help = 'https://alt-gnome.altlinux.team/matrix-to/#/#cassette-discussion:altlinux.org'

subdir('libtape')
if not get_option('sdk_only')
  subdir('app')
endif
