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

public sealed class Cassette.TrackQueueOptionsButton: TrackOptionsButton {

    public int position { get; set; }

    Gtk.Box get_toolbox (bool hexpand) {
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            hexpand = hexpand,
            halign = hexpand? Gtk.Align.FILL : Gtk.Align.START,
            homogeneous = true,
        };

        var dislike_button = new DislikeButton () {
            css_classes = {"flat"},
        };
        dislike_button.init_content (track_info.id);
        box.append (dislike_button);

        var like_button = new LikeButton (Client.LikableType.TRACK) {
            css_classes = {"flat"},
        };
        like_button.init_content (track_info.id);
        box.append (like_button);

        var save_stack = new SaveStack () {
            show_anyway = true,
        };
        save_stack.init_content (track_info.id);
        box.append (save_stack);

        return box;
    }

    construct {
        SimpleAction remove_from_queue_action = new SimpleAction ("remove-from-queue", null);
        remove_from_queue_action.activate.connect (() => {
            player.remove_track_by_pos (position);
        });
        actions.add_action (remove_from_queue_action);
    }

    protected override Gtk.Widget[] get_popover_menu_widgets () {
        return {
            get_toolbox (true),
        };
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

    protected override Gtk.Widget[] get_dialog_menu_widgets () {
        var like_button = new LikeButton (Client.LikableType.TRACK);
        like_button.init_content (track_info.id);

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
            },
            get_toolbox (false),
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
