/* player_bar.vala
 *
 * Copyright 2023 Rirusha
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


using CassetteClient;


namespace Cassette {
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/player_bar.ui")]
    public class PlayerBar : Adw.Bin {
        [GtkChild]
        unowned Gtk.Revealer revealer;
        [GtkChild]
        unowned Gtk.Label current_time_mark;
        [GtkChild]
        unowned Gtk.Label total_time_mark;
        [GtkChild]
        unowned Gtk.Scale slider;
        [GtkChild]
        unowned Gtk.Box slider_overlay;
        [GtkChild]
        unowned Gtk.Button prev_track_button;
        [GtkChild]
        unowned CoverImage cover_image;
        [GtkChild]
        unowned Gtk.Label track_name_label;
        [GtkChild]
        unowned Gtk.Label track_version_label;
        [GtkChild]
        unowned Gtk.Label track_authors_label;
        [GtkChild]
        unowned DislikeButton dislike_button;
        [GtkChild]
        unowned LikeButton like_button;
        [GtkChild]
        unowned Gtk.Button queue_show_button;
        //  [GtkChild]
        //unowned Gtk.Button temp_playlist_button;
        [GtkChild]
        unowned SaveStack save_stack;
        [GtkChild]
        unowned Gtk.Button shuffle_button;
        [GtkChild]
        unowned Gtk.Button repeat_button;
        [GtkChild]
        unowned Gtk.ScaleButton volume_button;
        [GtkChild]
        unowned InfoMarks info_marks;
        [GtkChild]
        unowned Gtk.Button track_info_button;

        public MainWindow window { get; construct set; }

        YaMAPI.Track track_info = new YaMAPI.Track ();

        Gtk.EventControllerMotion slider_motion_controller;

        public PlayerBar (MainWindow window) {
            Object (window: window);
        }

        construct {
            player.play_slider = slider;

            clear ();

            volume_button.set_icons ({"audio-volume-muted-symbolic", "audio-volume-high-symbolic", "audio-volume-low-symbolic", "audio-volume-medium-symbolic"});
            volume_button.value_changed.connect ((widget, volume) => {
                player.volume = 0.01 * volume;
            });

            storager.settings.bind ("volume", volume_button, "value", SettingsBindFlags.DEFAULT);

            var gesture_click = new Gtk.GestureClick ();
            gesture_click.pressed.connect ((n_press, x, y) => {
                //  Проверка нужна для редких случаев, когда пользователь нажал ПКМ вне слайдера при зажатой ЛКМ.
                if (slider_motion_controller != null) {
                    slider_overlay.remove_controller (slider_motion_controller);
                }

                slider_motion_controller = new Gtk.EventControllerMotion ();
                slider_motion_controller.motion.connect ((x, y) => {
                    var value = x * (slider.adjustment.upper / slider_overlay.get_width ());
                    slider.set_value (value);
                });
                slider_overlay.add_controller (slider_motion_controller);
                slider_motion_controller.motion (x, y);

                player.is_slider_moving = true;
            });
            gesture_click.released.connect (() => {
                slider_overlay.remove_controller (slider_motion_controller);
                slider_motion_controller = null;
                player.seek ((int) (slider.get_value () * 1000));
                //  mouse_time_mark.label = "";

                player.is_slider_moving = false;
            });
            slider_overlay.add_controller (gesture_click);

            slider.value_changed.connect (() => {
                current_time_mark.label = sec2str ((int) slider.get_value (), true);
            });

            player.bind_property ("is-loading", this, "sensitive", BindingFlags.INVERT_BOOLEAN);

            //  play_button.notify["is-playing"].connect (player_state_changed);
            player.notify["player-state"].connect (player_state_changed);
            player.notify["player-mod"].connect (player_mod_changed);

            var playerbar_actions = new SimpleActionGroup ();

            SimpleAction prev_action = new SimpleAction ("prev", null);
            prev_action.activate.connect (() => {
                player.prev ();
            });
            playerbar_actions.add_action (prev_action);

            SimpleAction next_action = new SimpleAction ("next", null);
            next_action.activate.connect (() => {
                player.next ();
            });
            playerbar_actions.add_action (next_action);

            insert_action_group ("playerbar", playerbar_actions);

            var track_actions = new SimpleActionGroup ();

            SimpleAction share_action = new SimpleAction ("share", null);
            share_action.activate.connect (() => {
                activate_action ("app.share-current-track", null);
            });
            track_actions.add_action (share_action);

            SimpleAction add_next_action = new SimpleAction ("add-next", null);
            add_next_action.activate.connect (() => {
                player.add_track (track_info, true);
            });
            track_actions.add_action (add_next_action);

            SimpleAction add_end_action = new SimpleAction ("add-end", null);
            add_end_action.activate.connect (() => {
                player.add_track (track_info, false);
            });
            track_actions.add_action (add_end_action);

            SimpleAction add_to_playlist_action = new SimpleAction ("add-to-playlist", null);
            add_to_playlist_action.activate.connect (() => {
                var win = new PlaylistChooseWindow (track_info) {
                    transient_for = Cassette.application.main_window,
                };
                win.present ();
            });
            track_actions.add_action (add_to_playlist_action);

            insert_action_group ("track", track_actions);

            track_info_button.clicked.connect (() => {
                if (track_info_button.has_css_class ("pressed")) {
                    window.sidebar.close ();
                } else {
                    window.sidebar.show_track_info (track_info);
                }
            });

            queue_show_button.clicked.connect (() => {
                if (queue_show_button.has_css_class ("pressed")) {
                    window.sidebar.close ();
                } else {
                    window.sidebar.show_queue ();
                }
            });

            set_repeat_button_view ();
            set_shuffle_button_view ();

            window.sidebar.notify["track-detailed"].connect (() => {
                if (window.sidebar.track_detailed != null && track_info != null) {
                    if (window.sidebar.track_detailed.track_info.id == track_info.id) {
                        track_info_button.add_css_class ("pressed");
                        return;
                    }
                }

                track_info_button.remove_css_class ("pressed");
            });

            window.sidebar.notify["is-shown"].connect (() => {
                if (window.sidebar.is_shown == false) {
                    queue_show_button.remove_css_class ("pressed");
                    track_info_button.remove_css_class ("pressed");
                }
            });
            window.sidebar.notify["track-list"].connect (() => {
                if (window.sidebar.track_list == null) {
                    queue_show_button.remove_css_class ("pressed");
                } else {
                    queue_show_button.add_css_class ("pressed");
                }
            });

            yam_talker.init_end.connect (update_queue);
        }

        public async void update_queue () {
            YaMAPI.Queue? queue = null;

            threader.add_single (() => {
                queue = yam_talker.get_queue ();

                Idle.add (update_queue.callback);
            });

            yield;

            if (player.current_track != null) {
                if (player.current_track.id == queue.tracks[queue.current_index].id) {
                    return;
                }
            }

            //  if (player.player_mod != null) {
            //      return;
            //  }

            if (queue != null) {
                if (queue.context.type_ == "radio") {

                } else {
                    player.start_queue_init (queue);
                    set_shuffle_button_view ();
                }
            }
        }

        void player_mod_changed () {
            if (player.player_mod is Player.PlayerTL) {
                shuffle_button.visible = true;
                repeat_button.visible = true;
                queue_show_button.visible = true;
                prev_track_button.visible = true;
            } else if (player.player_mod is Player.PlayerFL) {
                shuffle_button.visible = false;
                repeat_button.visible = false;
                queue_show_button.visible = false;
                prev_track_button.visible = false;
            }
        }

        void player_state_changed () {
            if (player.player_state == Player.PlayerState.PLAYING) {
                if (player.current_track != null) {
                    show_track (player.current_track);
                }
            }
            if (player.current_track == null) {
                clear ();
                revealer.reveal_child = false;
            }
        }

        void show_track (YaMAPI.Track track_info) {
            this.track_info = track_info;

            if (window.sidebar.track_detailed != null) {
                if (track_info.id == window.sidebar.track_detailed.track_info.id) {
                    track_info_button.add_css_class ("pressed");
                } else {
                    track_info_button.remove_css_class ("pressed");
                }
            }


            var adjustment = slider.get_adjustment ();
            adjustment.set_upper (ms2sec (track_info.duration_ms));

            track_name_label.label = track_info.title;
            track_version_label.label = track_info.version;
            track_authors_label.label = track_info.get_artists_names ();

            if (track_info.ugc) {
                action_set_enabled ("track.share", false);
                dislike_button.visible = false;
            } else {
                action_set_enabled ("track.share", true);
                dislike_button.visible = true;
            }

            info_marks.is_exp = track_info.explicit;
            info_marks.is_child = track_info.is_suitable_for_children;
            info_marks.replaced_by = track_info.substituted;

            if (player.player_mod is Player.PlayerTL) {
                queue_show_button.visible = true;
            } else {
                queue_show_button.visible = false;
            }

            total_time_mark.label = ms2str (track_info.duration_ms, true);

            like_button.init_content (track_info.id);
            dislike_button.init_content (track_info.id);
            save_stack.init_content (track_info.id);
            cover_image.init_content (track_info, TRACK_ART_SIZE);
            cover_image.load_image.begin ();

            revealer.reveal_child = true;
        }

        void clear () {
            sensitive = false;

            track_name_label.label = "";
            track_version_label.label = "";
            track_authors_label.label = "";

            dislike_button.visible = true;
            info_marks.is_exp = false;
            info_marks.is_child = false;
            info_marks.replaced_by = null;
            queue_show_button.visible = false;
            total_time_mark.label = "";

            save_stack.clear ();
            cover_image.clear ();
        }

        public void roll_shuffle_mode () {
            switch (player.shuffle_mode) {
                case Player.ShuffleMode.OFF:
                    player.shuffle_mode = Player.ShuffleMode.ON;
                    break;
                case Player.ShuffleMode.ON:
                    player.shuffle_mode = Player.ShuffleMode.OFF;
                    break;
            }
            set_shuffle_button_view ();
        }

        void set_shuffle_button_view () {
            switch (player.shuffle_mode) {
                case Player.ShuffleMode.ON:
                    shuffle_button.add_css_class ("pressed");
                    break;
                case Player.ShuffleMode.OFF:
                    shuffle_button.remove_css_class ("pressed");
                    break;
            }
        }

        public void roll_repeat_mode () {
            switch (player.repeat_mode) {
                case Player.RepeatMode.OFF:
                    player.repeat_mode = Player.RepeatMode.REPEAT_ALL;
                    break;
                case Player.RepeatMode.REPEAT_ALL:
                    player.repeat_mode = Player.RepeatMode.REPEAT_ONE;
                    break;
                case Player.RepeatMode.REPEAT_ONE:
                    player.repeat_mode = Player.RepeatMode.OFF;
                    break;
            }
            set_repeat_button_view ();
        }

        void set_repeat_button_view () {
            switch (player.repeat_mode) {
                case Player.RepeatMode.REPEAT_ALL:
                    repeat_button.set_icon_name ("media-playlist-repeat-symbolic");
                    repeat_button.add_css_class ("pressed");
                    break;
                case Player.RepeatMode.REPEAT_ONE:
                    repeat_button.set_icon_name ("media-playlist-repeat-song-symbolic");
                    repeat_button.add_css_class ("pressed");
                    break;
                case Player.RepeatMode.OFF:
                    repeat_button.set_icon_name ("media-playlist-repeat-symbolic");
                    repeat_button.remove_css_class ("pressed");
                    break;
            }
        }
    }
}
