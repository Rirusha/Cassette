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


public class Cassette.PlaylistOptionsButton : CustomMenuButton {

    protected override Gtk.Widget[] get_popover_menu_items () {
        assert_not_reached ();
    }

    protected override Gtk.Widget[] get_dialog_menu_items () {
        assert_not_reached ();
    }

    //  protected override void set_menu () {
    //      global_menu.append (_("My wave on playlist"), "playlist.my-wave");
    //      global_menu.append (_("Add to queue"), "playlist.add-to-queue");
    //      other_menu.append (_("Share"), "playlist.share");
    //  }

    //  public void add_delete_playlist_action () {
    //      global_menu.append (_("Delete playlist"), "playlist.delete-playlist");
    //  }
}
