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

public class Cassette.TrackQueueOptionsButton: TrackOptionsButton {

    public int position { get; set; }

    construct {
        SimpleAction remove_from_queue_action = new SimpleAction ("remove-from-queue", null);
        remove_from_queue_action.activate.connect (() => {
            player.remove_track_by_pos (position);
        });
        actions.add_action (remove_from_queue_action);
    }

    protected override CustomMenuButton.MenuItem[] get_popover_menu_items () {
        return {
            {_("My Vibe by track"), "track.my-vibe", 0},
            {_("Show info"), "track.show-info", 0},
            {_("Play next"), "track.add-next", 1},
            {_("Add to queue"), "track.add-end", 1},
            {_("Add to playlist"), "track.add-to-playlist", 2},
            {_("Remove from queue"), "track.remove-from-queue", 2},
            {_("Save"), "track.save", 3},
            {_("Share"), "track.share", 3}
        };
    }

    protected override CustomMenuButton.MenuItem[] get_dialog_menu_items () {
        return {
            {_("Play next"), "track.add-next", 1},
            {_("Add to queue"), "track.add-end", 1},
            {_("Add to playlist"), "track.add-to-playlist", 2},
            {_("Remove from queue"), "track.remove-from-queue", 2},
            {_("Save"), "track.save", 3},
            {_("Share"), "track.share", 3}
        };
    }
}
