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

[GtkTemplate (ui = "/space/rirusha/Cassette/ui/track-queue-content.ui")]
public class Cassette.TrackQueue : TrackRow {

    [GtkChild]
    unowned TrackInfoPanel info_panel;
    [GtkChild]
    unowned Gtk.Label duration_label;
    [GtkChild]
    unowned TrackQueueOptionsButton track_queue_options_button;

    public int position { get; construct; }

    protected override PlayMarkTrack play_mark_track {
        owned get {
            return info_panel.get_play_mark_track ();
        }
    }

    public TrackQueue (YaMAPI.Track track_info, int position) {
        Object (track_info: track_info, position: position);
    }

    construct {
        play_mark_track.triggered_not_playing.connect (() => {
            player.change_track (track_info);
        });

        play_mark_track.bind_property (
            "is-current-playing",
            this, "is-current-playing",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE
        );

        info_panel.track_info = track_info;

        duration_label.label = ms2str (track_info.duration_ms, true);

        info_panel.show_play_button ();
        play_mark_track.init_content (track_info.id);
        track_queue_options_button.track_info = track_info;
        track_queue_options_button.position = position;
        info_panel.position = position + 1;
    }
}
