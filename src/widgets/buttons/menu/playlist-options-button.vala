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

public class Cassette.PlaylistOptionsButton : CustomMenuButton {

    public Client.YaMAPI.Playlist playlist_info { get; set; }

    construct {
        SimpleAction share_action = new SimpleAction ("share", null);
        share_action.activate.connect (() => {
            playlist_share (playlist_info);
        });
        actions.add_action (share_action);

        SimpleAction add_to_queue_action = new SimpleAction ("add-to-queue", null);
        add_to_queue_action.activate.connect (() => {
            var track_list = playlist_info.get_filtered_track_list (
                Cassette.settings.get_boolean ("explicit-visible"),
                Cassette.settings.get_boolean ("child-visible")
            );

            player.add_many (track_list);
        });
        actions.add_action (add_to_queue_action);

        SimpleAction vibe_action = new SimpleAction ("my-vibe", null);
        vibe_action.activate.connect (() => {
            player.start_flow ("playlist:%s_%s".printf (playlist_info.uid, playlist_info.kind));
        });
        actions.add_action (vibe_action);
    }

    protected override string get_title_label () {
        return _("Playlist '%s'").printf (playlist_info.title);
    }

    protected override MenuItem[] get_popover_menu_items () {
        return {
            {_("My Vibe by playlist"), "actions.my-vibe", 0},
            {_("Add to queue"), "actions.add-to-queue", 1},
            {_("Share"), "actions.share", 1}
        };
    }

    protected override Gtk.Widget[] get_dialog_menu_widgets () {
        return {
            new ActionCardStation (new Client.YaMAPI.Rotor.StationInfo () {
                id = new Client.YaMAPI.Rotor.Id () {
                    type_ = "playlist",
                    tag = "%s_%s".printf (playlist_info.uid, playlist_info.kind)
                },
                name = _("My Vibe by playlist"),
                icon = new Client.YaMAPI.Icon ()
            }) {
                is_shrinked = true
            }
        };
    }

    protected override MenuItem[] get_dialog_menu_items () {
        return {
            {_("Add to queue"), "actions.add-to-queue", 1},
            {_("Share"), "actions.share", 1}
        };
    }
}
