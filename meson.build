project(
  'cassette',
  ['c', 'vala'],
  version: '0.1.01',
  meson_version: '>= 0.62.0',
  license: 'GPL-3.0-or-later',
)

i18n = import('i18n')
gnome = import('gnome')

gtk = dependency('gtk4', version: '>= 4.5')
libadwaita = dependency('libadwaita-1', version: '>= 1.2')
threads = dependency('threads')
libsoup = dependency('libsoup-3.0')
gdkpixbuf = dependency('gdk-pixbuf-2.0')
jsonglib = dependency('json-glib-1.0')
sqlite3 = dependency('sqlite3')
gee = dependency('gee-0.8')
libxml = dependency('libxml-2.0')
gstreamer = dependency('gstreamer-1.0')
gio = dependency('gio-2.0', version: '>= 2.72')

if get_option('profile') == 'development'
  name_prefix = '(Development) '
  postfix = '.Devel'
else
  name_prefix = ''
  postfix = ''
endif

app_id = 'com.github.Rirusha.Cassette@0@'.format(postfix)

conf = configuration_data()
conf.set_quoted('APP_ID', app_id)
conf.set_quoted('G_LOG_DOMAIN', app_id)
conf.set_quoted('NAME_PREFIX', name_prefix)
conf.set_quoted('PACKAGE_NAME', meson.project_name())
conf.set_quoted('PACKAGE_VERSION', meson.project_version())
conf.set_quoted('POSTFIX', postfix)
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
conf.set_quoted('GNOMELOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))

configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

subdir('po')
subdir('data')
subdir('src')

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true,
)

#########
# TESTS #
#########

# client_test_sources = [
#   'src/threader.vala',
#   'src/utils.vala',
#   'src/api/objects/yam_object.vala',
#   'src/api/objects/cover.vala',
#   'src/api/objects/track_short.vala',
#   'src/api/objects/download_info.vala',
#   'src/api/objects/account_info/account_info.vala',
#   'src/api/objects/account_info/avatar_info.vala',
#   'src/api/objects/account_info/passport_phone.vala',
#   'src/api/objects/account_info/plus.vala',
#   'src/api/objects/account_info/master_hub.vala',
#   'src/api/objects/account_info/plus.vala',
#   'src/api/objects/account_info/account.vala',
#   'src/api/objects/account_info/permissions.vala',
#   'src/api/objects/playlist/playlist.vala',
#   'src/api/objects/playlist/user.vala',
#   'src/api/objects/playlist/made_for.vala',
#   'src/api/objects/playlist/play_counter.vala',
#   'src/api/objects/playlist/playlist_absence.vala',
#   'src/api/objects/playlist/case_forms.vala',
#   'src/api/objects/playlist/liked_playlist.vala',
#   'src/api/objects/album/album.vala',
#   'src/api/objects/album/label.vala',
#   'src/api/objects/artist/artist.vala',
#   'src/api/objects/artist/counts.vala',
#   'src/api/objects/artist/ratings.vala',
#   'src/api/objects/artist/link.vala',
#   'src/api/objects/track/track.vala',
#   'src/api/objects/track/lyrics_info.vala',
#   'src/api/objects/track/meta_data.vala',
#   'src/api/objects/track/chart.vala',
#   'src/api/objects/queue/short_queue.vala',
#   'src/api/objects/queue/queue.vala',
#   'src/api/objects/queue/context.vala',
#   'src/api/objects/additional_info/similar_tracks.vala',
#   'src/api/objects/additional_info/lyrics.vala',
#   'src/api/objects/additional_info/lyrics_major.vala'
# ]

# test('Test Logger',
#   executable('logger_test',
#     sources: ['tests/logger_test.vala', 'src/logger.vala'],
#     dependencies: cassette_deps
#   )
# )

# test('Test Jsoner',
#   executable('jsoner_test',
#     sources: client_test_sources + ['src/api/jsoner.vala', 'src/logger.vala', 'tests/jsoner_test.vala'],
#     dependencies: cassette_deps
#   )
# )

# test('Test Utils',
#   executable('utils_test',
#     sources: ['src/utils.vala', 'tests/utils_test.vala'],
#     dependencies: cassette_deps
#   )
# )

# test('Test Info Database',
#   executable('info_db_test',
#     sources: ['src/cachier/info_db.vala', 'src/logger.vala', 'tests/info_db_test.vala'],
#     dependencies: cassette_deps
#   )
# )

# test('Test Storager',
#   executable('storager_test',
#     sources: client_test_sources + ['src/cachier/info_db.vala', 'src/cachier/storager.vala', 'src/logger.vala', 'src/api/jsoner.vala', 'tests/storager_test.vala'],
#     dependencies: cassette_deps
#   )
# )

