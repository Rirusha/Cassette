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

public class Cassette.TrackPlaylistOptionsButton: TrackOptionsButton {

    public Client.YaMAPI.Playlist playlist_info { get; set; }

    construct {
        SimpleAction remove_from_playlist_action = new SimpleAction ("remove-from-playlist", null);
        remove_from_playlist_action.activate.connect (() => {
            remove_track_from_playlist (track_info, playlist_info);
        });
        actions.add_action (remove_from_playlist_action);
    }

    protected override CustomMenuButton.MenuItem[] get_popover_menu_items () {
        return {
            {_("My Vibe by track"), "actions.my-vibe", 0},
            {_("Show info"), "actions.show-info", 0},
            {_("Play next"), "actions.add-next", 1},
            {_("Add to queue"), "actions.add-end", 1},
            {_("Add to playlist"), "actions.add-to-playlist", 2},
            {_("Remove from playlist"), "actions.remove-from-playlist", 2},
            {_("Save"), "actions.save", 3},
            {_("Share"), "actions.share", 3}
        };
    }

    protected override CustomMenuButton.MenuItem[] get_dialog_menu_items () {
        return {
            {_("Play next"), "actions.add-next", 1},
            {_("Add to queue"), "actions.add-end", 1},
            {_("Add to playlist"), "actions.add-to-playlist", 2},
            {_("Remove from playlist"), "actions.remove-from-playlist", 2},
            {_("Save"), "actions.save", 3},
            {_("Share"), "actions.share", 3}
        };
    }
}
