vapi_sources = files(
  'config.vapi',
)

cassette_gui_sources = files(
  'widgets/action_cards/custom.vala',
  'widgets/action_cards/station.vala',

  'widgets/begin/begin_dialog.vala',
  'widgets/begin/begin_view.vala',

  'widgets/buttons/just/play_buttons/abstract_play_button_default.vala',
  'widgets/buttons/just/play_buttons/abstract_play_button.vala',
  'widgets/buttons/just/play_buttons/play_button_action.vala',
  'widgets/buttons/just/play_buttons/play_button_context.vala',
  'widgets/buttons/just/play_buttons/play_button_track.vala',
  'widgets/buttons/just/abstract_custom_button.vala',
  'widgets/buttons/just/like_button.vala',
  'widgets/buttons/just/dislike_button.vala',
  'widgets/buttons/menu/abstract_menu_button.vala',
  'widgets/buttons/menu/primary_menu_button.vala',
  'widgets/buttons/menu/playlist_options_button.vala',
  'widgets/buttons/menu/track_options_button.vala',
  'widgets/buttons/menu/volume_button.vala',
  'widgets/buttons/label_button.vala',
  'widgets/buttons/playlist_create_button.vala',

  'widgets/cache_indicator/cache_indicator.vala',
  'widgets/cache_indicator/job_info_badge.vala',

  'widgets/lyrics/lyrics_line.vala',
  'widgets/lyrics/lyrics_panel.vala',

  'widgets/pages/abstract_loadable_page.vala',
  'widgets/pages/loading_page.vala',

  'widgets/preferences/cache_deletion_preferences.vala',
  'widgets/preferences/custom_page_preferences.vala',
  'widgets/preferences/custom_pages_preferences.vala',
  'widgets/preferences/preferences_dialog.vala',

  'widgets/shrinkable/application_window.vala',
  'widgets/shrinkable/bin.vala',

  'widgets/sidebar/childs/history.vala',
  'widgets/sidebar/childs/interface_sidebar_child.vala',
  'widgets/sidebar/childs/queue.vala',
  'widgets/sidebar/childs/track_info.vala',
  'widgets/sidebar/childs/wave_settings.vala',
  'widgets/sidebar/sidebar.vala',

  'widgets/track_list/track_list.vala',
  'widgets/track_list/track_row_base.vala',
  'widgets/track_list/tracks_model.vala',
  'widgets/track_list/tracks_view.vala',

  'widgets/track_rows/abstract_track_row_content.vala',
  'widgets/track_rows/default.vala',
  'widgets/track_rows/local.vala',
  'widgets/track_rows/placeholder.vala',
  'widgets/track_rows/queue.vala',
  'widgets/track_rows/ya_content.vala',

  'widgets/views/abstract_base.vala',
  'widgets/views/abstract_cachiable.vala',
  'widgets/views/abstract_with_tracks.vala',
  'widgets/views/cant_show.vala',
  'widgets/views/devel.vala',
  'widgets/views/disliked.vala',
  'widgets/views/main.vala',
  'widgets/views/playlist.vala',
  'widgets/views/playlists.vala',
  'widgets/views/stations.vala',
  
  'widgets/account_info_dialog.vala',
  'widgets/cover_image.vala',
  'widgets/header_bar.vala',
  'widgets/headered_scrolled_window.vala',
  'widgets/info_marks.vala',
  'widgets/loading_spinner.vala',
  'widgets/page_root.vala',
  'widgets/player_bar.vala',
  'widgets/playlist_choose_dialog.vala',
  'widgets/playlist_micro.vala',
  'widgets/playlist_row.vala',
  'widgets/save_stack.vala',
  'widgets/theme_switcher.vala',
  'widgets/track_carousel.vala',
  'widgets/track_info_panel.vala',
  'application.vala',
  'authenticator.vala',
  'main_window.vala',
  'main.vala',
  'pager.vala',
  'utils.vala',
)

subdir('client')

cassette_sources = [
  vapi_sources,
  blueprints,
  cassette_gui_sources,
  cassette_client_sources,
  resources
]

cassette_vala_args = [
  '--target-glib', '2.76',
  '--vapidir', meson.current_source_dir(),
  '--gresources', resource_files,
  '--gresourcesdir=data/'
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
  link_args: ['-lm'],
  dependencies: cassette_dependencies,
  install: true,
)