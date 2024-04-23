/* Copyright 2023-2024 Rirusha
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */


using Cassette.Client;


namespace Cassette {
    [GtkTemplate (ui = "/io/github/Rirusha/Cassette/ui/track-queue-content.ui")]
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

        public int position { get; set; }

        public TrackQueue (YaMAPI.Track track_info, int position) {
            Object (track_info: track_info, position: position);
        }

        construct {
            play_button.clicked_not_playing.connect (() => {
                player.change_track (track_info);
            });

            play_button.notify["is-current-playing"].connect (() => {
                if (play_button.is_current_playing) {
                    add_css_class ("track-row-playing");
                } else {
                    remove_css_class ("track-row-playing");
                }
            });

            set_values ();
        }

        public void set_values () {
            track_name_label.label = track_info.title;
            track_name_label.tooltip_text = track_info.title;

            info_marks.is_exp = track_info.is_explicit;
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
