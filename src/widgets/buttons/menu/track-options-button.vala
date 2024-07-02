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

public class Cassette.TrackOptionsButton: CustomMenuButton {

    public Client.YaMAPI.Track track_info { get; set; }

    construct {
        SimpleAction share_action = new SimpleAction ("share", null);
        share_action.activate.connect (() => {
            track_share (track_info);
        });
        actions.add_action (share_action);

        SimpleAction vibe_action = new SimpleAction ("my-vibe", null);
        vibe_action.activate.connect (() => {
            player.start_flow ("track:%s".printf (track_info.id));
        });
        actions.add_action (vibe_action);

        SimpleAction add_next_action = new SimpleAction ("add-next", null);
        add_next_action.activate.connect (() => {
            player.add_track (track_info, true);
        });
        actions.add_action (add_next_action);

        SimpleAction show_info_action = new SimpleAction ("show-info", null);
        show_info_action.activate.connect (() => {
            application.main_window.window_sidebar.show_track_info (track_info);
        });
        actions.add_action (show_info_action);

        SimpleAction add_end_action = new SimpleAction ("add-end", null);
        add_end_action.activate.connect (() => {
            player.add_track (track_info, false);
        });
        actions.add_action (add_end_action);

        SimpleAction add_to_playlist_action = new SimpleAction ("add-to-playlist", null);
        add_to_playlist_action.activate.connect (() => {
            add_track_to_playlist (track_info);
        });
        actions.add_action (add_to_playlist_action);

        SimpleAction save_action = new SimpleAction ("save", null);
        save_action.activate.connect (() => {
            Client.Cachier.save_track.begin (track_info);
        });
        actions.add_action (save_action);
    }

    protected override Gtk.Widget? get_title_widget () {
        return new Gtk.Button () {
            child = new TrackInfoPanel (Gtk.Orientation.HORIZONTAL) {
                track_info = track_info
            },
            action_name = "actions.show-info"
        };
    }

    protected override MenuItem[] get_popover_menu_items () {
        return {
            {_("My Vibe by track"), "actions.my-vibe", 0},
            {_("Show info"), "actions.show-info", 0},
            {_("Play next"), "actions.add-next", 1},
            {_("Add to queue"), "actions.add-end", 1},
            {_("Add to playlist"), "actions.add-to-playlist", 2},
            {_("Save"), "actions.save", 3},
            {_("Share"), "actions.share", 3}
        };
    }

    protected override Gtk.Widget[] get_dialog_menu_widgets () {
        return {
            new ActionCardStation (new Client.YaMAPI.Rotor.StationInfo () {
                id = new Client.YaMAPI.Rotor.Id () {
                    type_ = "track",
                    tag = track_info.id
                },
                name = _("My Vibe by track"),
                icon = new Client.YaMAPI.Icon ()
            }) {
                is_shrinked = true
            }
        };
    }

    protected override MenuItem[] get_dialog_menu_items () {
        return {
            {_("Play next"), "actions.add-next", 1},
            {_("Add to queue"), "actions.add-end", 1},
            {_("Add to playlist"), "actions.add-to-playlist", 2},
            {_("Save"), "actions.save", 3},
            {_("Share"), "actions.share", 3}
        };
    }
}
