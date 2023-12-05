/* track_queue_content.vala
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
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/track_queue_content.ui")]
    public class TrackQueue : Gtk.Frame {
        [GtkChild]
        unowned PlayButtonTrack play_button;
        [GtkChild]
        unowned Gtk.Label track_name_label;
        [GtkChild]
        unowned Gtk.Label track_version_label;
        [GtkChild]
        unowned Gtk.Label track_authors_label;
        [GtkChild]
        unowned InfoMarks info_marks;
        [GtkChild]
        unowned LikeButton like_button;
        [GtkChild]
        unowned Gtk.Label duration_label;
        [GtkChild]
        unowned TrackOptionsButton track_options_button;

        public YaMAPI.Track track_info { get; construct set; }

        public uint position { get; set; }

        public TrackQueue (YaMAPI.Track track_info, uint position) {
            Object (track_info: track_info, position: position);
        }

        construct {
            play_button.clicked_not_playing.connect (() => {
                player.change_track (track_info);
            });

            var actions = new SimpleActionGroup ();

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

            track_options_button.add_remove_from_queue_action ();

            SimpleAction remove_from_queue_action = new SimpleAction ("remove-from-queue", null);
            remove_from_queue_action.activate.connect (() => {
                player.remove_track (position);
            });
            actions.add_action (remove_from_queue_action);

            insert_action_group ("track", actions);

            play_button.notify["is-playing"].connect (() => {
                if (play_button.is_playing) {
                    add_css_class ("playing-track");
                } else {
                    remove_css_class ("playing-track");
                }
            });

            set_values ();
        }

        public void set_values () {
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
            duration_label.label = ms2str (track_info.duration_ms, true);

            like_button.init_content (track_info.id);
            play_button.init_content (track_info.id);
        }
    }
}