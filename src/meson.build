vapi_sources = files(
  'config.vapi',
)


cassette_gui_sources = files(
  'main.vala',
  'application.vala',
  'main_window.vala',
  'utils.vala',
  'pager.vala',
  'authenticator.vala',
  'widgets/playlist_create_button.vala',
  'widgets/player_bar.vala',
  'widgets/playlist_micro.vala',
  'widgets/sidebar.vala',
  'widgets/save_stack.vala',
  'widgets/label_button.vala',
  'widgets/custom_button.vala',
  'widgets/like_button.vala',
  'widgets/dislike_button.vala',
  'widgets/playlist_row.vala',
  'widgets/info_marks.vala',
  'widgets/account_info_window.vala',
  'widgets/auth_window.vala',
  'widgets/playlist_choose_window.vala',
  'widgets/track_list/track_list.vala',
  'widgets/track_list/tracks_model.vala',
  'widgets/track_list/tracks_view.vala',
  'widgets/track_list/track_row_base.vala',
  'widgets/play_button/play_button.vala',
  'widgets/play_button/play_button_context.vala',
  'widgets/play_button/play_button_default.vala',
  'widgets/play_button/play_button_action.vala',
  'widgets/play_button/play_button_track.vala',
  'widgets/options_button/track_options_button.vala',
  'widgets/options_button/options_button.vala',
  'widgets/options_button/playlist_options_button.vala',
  'widgets/cover_image.vala',
  'widgets/lyrics_line.vala',
  'widgets/lyrics_panel.vala',
  'widgets/track_detailed.vala',
  'widgets/preferences/custom_pages_preferences.vala',
  'widgets/preferences/cache_deletion_preferences.vala',
  'widgets/preferences/custom_page_preferences.vala',
  'widgets/preferences/preferences_window.vala',
  'widgets/track_rows/track_local_content.vala',
  'widgets/track_rows/track_default_content.vala',
  'widgets/track_rows/track_queue_content.vala',
  'widgets/track_rows/track_placeholder.vala',
  'widgets/views/main_view.vala',
  'widgets/views/with_tracks_view.vala',
  'widgets/views/base_view.vala',
  'widgets/views/root_view.vala',
  'widgets/views/disliked_tracks_view.vala',
  'widgets/views/cachiable_view.vala',
  'widgets/views/playlist_view.vala',
  'widgets/views/playlists_view.vala',
  'widgets/views/cant_show_view.vala',
  'widgets/auth_window/auth_window.vala',
  'widgets/auth_window/phone_entry.vala'
)

subdir('client')

cassette_sources = [
  vapi_sources,
  cassette_gui_sources,
  cassette_client_sources,
  resources
]

cassette_vala_args = [
  '--target-glib', '2.76',
  '--vapidir', meson.current_source_dir(),
  '--gresources', resource_files
]


cassette_c_args = [
  '-include', 'config.h',
]

executable(
  'cassette',
  cassette_sources,
  include_directories: config_h_dir,
  vala_args: cassette_vala_args,
  c_args: cassette_c_args,
  dependencies: cassette_dependencies,
  install: true,
)