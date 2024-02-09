/* Copyright 2023-2024 Rirusha
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
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/track_default_content.ui")]
    public class TrackDefault : Gtk.Frame {

        [GtkChild]
        unowned CoverImage cover_image;
        [GtkChild]
        unowned PlayButtonTrack play_button;
        [GtkChild]
        unowned Gtk.Label track_name_label;
        [GtkChild]
        unowned Gtk.Label track_version_label;
        [GtkChild]
        unowned InfoMarks info_marks;
        [GtkChild]
        unowned Gtk.Label track_authors_label;
        [GtkChild]
        unowned SaveStack save_stack;
        [GtkChild]
        unowned LikeButton like_button;
        [GtkChild]
        unowned DislikeButton dislike_button;
        [GtkChild]
        unowned Gtk.Revealer dislike_button_revealer;
        [GtkChild]
        unowned Gtk.Label duration_label;
        [GtkChild]
        unowned TrackOptionsButton track_options_button;

        public YaMAPI.Track track_info { get; construct set; }
        public HasTrackList yam_object { get; construct set; }

        public TrackDefault (YaMAPI.Track track_info, HasTrackList yam_object) {
            Object (track_info: track_info, yam_object: yam_object);
        }

        // ! Не стоит использовать конструктор with_dislike_button со списком, в котором есть пользовательские треки
        public TrackDefault.with_dislike_button (YaMAPI.Track track_info, HasTrackList yam_object) {
            Object (track_info: track_info, yam_object: yam_object);
            dislike_button_revealer.reveal_child = true;
        }

        construct {
            play_button.clicked_not_playing.connect (form_queue);

            var actions = new SimpleActionGroup ();

            var playlist_info = yam_object as YaMAPI.Playlist;
            if (playlist_info != null) {
                if (playlist_info.kind != "3") {
                    track_options_button.add_remove_from_playlist_action ();

                    SimpleAction remove_from_playlist_action = new SimpleAction ("remove-from-playlist", null);
                    remove_from_playlist_action.activate.connect (() => {
                        remove_from_playlist_async.begin ();
                    });
                    actions.add_action (remove_from_playlist_action);
                }
            }

            if (track_info.ugc == false) {
                SimpleAction share_action = new SimpleAction ("share", null);
                share_action.activate.connect (() => {
                    track_share (track_info);
                });
                actions.add_action (share_action);
            }

            SimpleAction add_to_playlist_action = new SimpleAction ("add-to-playlist", null);
            add_to_playlist_action.activate.connect (() => {
                var win = new PlaylistChooseWindow (track_info) {
                    transient_for = Cassette.application.main_window,
                };
                win.present ();
            });
            actions.add_action (add_to_playlist_action);

            SimpleAction add_next_action = new SimpleAction ("add-next", null);
            add_next_action.activate.connect (() => {
                player.add_track (track_info, true);
            });
            actions.add_action (add_next_action);

            SimpleAction add_end_action = new SimpleAction ("add-end", null);
            add_end_action.activate.connect (() => {
                player.add_track (track_info, false);
            });
            actions.add_action (add_end_action);

            track_options_button.add_save_action ();
            SimpleAction save_action = new SimpleAction ("save", null);
            save_action.activate.connect (() => {
                save_track.begin (track_info);
            });
            actions.add_action (save_action);

            play_button.notify["is-playing"].connect (() => {
                if (play_button.is_playing) {
                    play_button.visible = true;
                    add_css_class ("playing-track");
                } else {
                    play_button.visible = false;
                    remove_css_class ("playing-track");
                }
            });

            insert_action_group ("track", actions);

            set_values ();
        }

        public async void remove_from_playlist_async () {
            var track_info = _track_info;
            var playlist = (YaMAPI.Playlist) yam_object;

            int position = -1;
            for (int i = 0; i < playlist.tracks.size; i++) {
                if (track_info.id == playlist.tracks[i].id) {
                    position = i;
                    break;
                }
            }

            threader.add (() => {
                yam_talker.remove_tracks_from_playlist (playlist.kind, position, playlist.revision);

                Idle.add (remove_from_playlist_async.callback);
            });

            yield;
        }

        void set_values () {
            var motion_controller = new Gtk.EventControllerMotion ();
            add_controller (motion_controller);

            track_name_label.label = track_info.title;
            track_name_label.tooltip_text = track_info.title;

            info_marks.is_exp = track_info.explicit;
            info_marks.is_child = track_info.is_suitable_for_children;
            info_marks.replaced_by = track_info.substituted;

            if (track_info.version != null) {
                track_version_label.label = track_info.version;
                track_name_label.tooltip_text += ", " + track_info.version;
                track_version_label.tooltip_text = track_name_label.tooltip_text;
            }
            track_authors_label.label = track_info.get_artists_names ();
            track_authors_label.tooltip_text = track_info.get_artists_names ();
            if (track_info.available) {
                duration_label.label = ms2str (track_info.duration_ms, true);
                motion_controller.enter.connect ((mc, x, y) => {
                    play_button.visible = true;
                });
                motion_controller.leave.connect ((mc) => {
                    if (!play_button.is_playing) {
                        play_button.visible = false;
                    }
                });
            } else {
                add_css_class ("not-available");

                track_name_label.sensitive = false;
                track_authors_label.sensitive = false;
                duration_label.label = "";
                track_options_button.sensitive = false;

                this.tooltip_text = _("Track is not available");
            }

            like_button.init_content (track_info.id);
            dislike_button.init_content (track_info.id);
            play_button.init_content (track_info.id);
            cover_image.init_content (track_info, TRACK_ART_SIZE);

            cover_image.load_image.begin ();

            save_stack.init_content (track_info.id);
        }

        void form_queue () {
            var track_list = yam_object.get_filtered_track_list (
                storager.settings.get_boolean ("explicit-visible"),
                storager.settings.get_boolean ("child-visible"),
                track_info.id
            );

            var queue = new YaMAPI.Queue () {
                context = YaMAPI.Context.from_obj ((HasID) yam_object),
                tracks = track_list,
                current_index = track_list.index_of (track_info)
            };

            player.start_queue (queue);
        }
    }
}
