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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */


public class Cassette.TrackOptionsButton : CustomMenuButton {

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

        SimpleAction add_end_action = new SimpleAction ("add-end", null);
        add_end_action.activate.connect (() => {
            player.add_track (track_info, false);
        });
        actions.add_action (add_end_action);
    }

    protected override MenuItem[] get_popover_menu_items () {
        return {
            {_("My Vibe by track"), "track.my-vibe", 0},
            {_("Play next"), "track.add-next", 0},
            {_("Add to queue"), "track.add-end", 0},
            {_("Add to playlist"), "track.add-to-playlist", 1},
            {_("Save"), "track.save", 2},
            {_("Share"), "track.share", 3}
        };
    }

    protected override Gtk.Widget[] get_dialog_menu_widgets () {
        return {
            new TrackInfoPanel (Gtk.Orientation.HORIZONTAL) {
                track_info = track_info
            },
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
            {_("Play next"), "track.add-next", 0},
            {_("Add to queue"), "track.add-end", 0},
            {_("Add to playlist"), "track.add-to-playlist", 1},
            {_("Save"), "track.save", 2},
            {_("Share"), "track.share", 3}
        };
    }

    //  protected override void set_menu () {
    //      queue_menu.append (_("Play next"), "track.add-next");
    //      queue_menu.append (_("Add to queue"), "track.add-end");

    //      global_menu.append (_("My wave on track"), "track.my-wave");
    //      global_menu.append (_("Add to playlist"), "track.add-to-playlist");

    //      other_menu.append (_("Share"), "track.share");
    //  }

    //  public void add_remove_from_playlist_action () {
    //      add_menu.append (_("Remove from playlist"), "track.remove-from-playlist");
    //  }

    //  public void add_remove_from_queue_action () {
    //      queue_menu.append (_("Remove from queue"), "track.remove-from-queue");
    //  }

    //  public void add_save_action () {
    //      other_menu.prepend (_("Save"), "track.save");
    //  }
}
