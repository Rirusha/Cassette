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


[GtkTemplate (ui = "/space/rirusha/Cassette/ui/devel-view.ui")]
public class Cassette.DevelView : BaseView {

    [GtkChild]
    unowned Gtk.ToggleButton hide_player_bar_button;
    [GtkChild]
    unowned Gtk.Button stations_view_button;
    [GtkChild]
    unowned Gtk.ScrolledWindow scrolled_window;
    [GtkChild]
    unowned TrackCarousel track_carousel;

    construct {
        stations_view_button.clicked.connect (() => {
            root_view.add_view (new StationsView ());
        });

        hide_player_bar_button.bind_property (
            "active",
            application.main_window,
            "player-bar-is-visible",
            BindingFlags.DEFAULT | BindingFlags.INVERT_BOOLEAN | BindingFlags.SYNC_CREATE
        );

        scrolled_window.vadjustment.value_changed.connect (() => {
            scrolled_window.vadjustment.value = 0.0;
        });
    }

    void set_values () {
        show_ready ();
    }

    public async override void first_show () {
        set_values ();
    }

    public async override bool try_load_from_cache () {
        return true;
    }

    public async override int try_load_from_web () {
        return -1;
    }

    public async override void refresh () {

    }
}
