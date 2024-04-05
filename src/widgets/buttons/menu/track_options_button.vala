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

    protected override Gtk.Widget[] get_menu_items () {
        return {};
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
