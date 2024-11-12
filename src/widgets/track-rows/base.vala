/* Copyright 2023-2024 Vladimir Vaskov
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
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Cassette.Client;

[GtkTemplate (ui = "/space/rirusha/Cassette/ui/track-base-content.ui")]
public class Cassette.TrackBase: TrackRow {

    [GtkChild]
    unowned TrackInfoPanel info_panel;
    [GtkChild]
    unowned Gtk.Label duration_label;
    [GtkChild]
    unowned TrackOptionsButton track_options_button;

    public HasTrackList yam_object { get; construct; }

    protected override PlayMarkTrack play_mark_track {
        owned get {
            return info_panel.get_play_mark_track ();
        }
    }

    public TrackBase (YaMAPI.Track track_info, HasTrackList yam_object) {
        Object (track_info: track_info, yam_object: yam_object);
    }

    construct {
        play_mark_track.triggered_not_playing.connect (form_queue);

        play_mark_track.notify["is-current-playing"].connect (() => {
            is_current_playing = play_mark_track.is_current_playing;

            if (play_mark_track.is_current_playing) {
                info_panel.show_play_button ();

            } else {
                info_panel.show_cover ();
            }
        });

        var motion_controller = new Gtk.EventControllerMotion ();
        add_controller (motion_controller);

        info_panel.track_info = track_info;

        if (track_info.available) {
            duration_label.label = ms2str (track_info.duration_ms, true);
            motion_controller.enter.connect ((mc, x, y) => {
                info_panel.show_play_button ();
            });
            motion_controller.leave.connect ((mc) => {
                if (!play_mark_track.is_current_playing) {
                    info_panel.show_cover ();
                }
            });

        } else {
            add_css_class ("not-available");

            info_panel.sensitive = false;
            duration_label.label = "";
            track_options_button.sensitive = false;

            this.tooltip_text = _("Track is not available");
        }

        play_mark_track.init_content (track_info.id);
        track_options_button.track_info = track_info;
    }

    void form_queue () {
        var track_list = yam_object.get_filtered_track_list (
            Cassette.settings.get_boolean ("explicit-visible"),
            Cassette.settings.get_boolean ("child-visible"),
            track_info.id
        );

        player.start_track_list (
            track_list,
            get_context_type (yam_object),
            yam_object.oid,
            track_list.index_of (track_info),
            get_context_description (yam_object)
        );
    }
}
