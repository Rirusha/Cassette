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

[GtkTemplate (ui = "/space/rirusha/Cassette/ui/main-view.ui")]
public class Cassette.MainView : BaseView {

    [GtkChild]
    unowned Adw.StatusPage status_page;
    [GtkChild]
    unowned Gtk.Button stations_view_button;

    public MainView () {
        Object ();
    }

    construct {
        status_page.icon_name = "%s-symbolic".printf (Config.APP_ID_DYN);

        stations_view_button.clicked.connect (() => {
            root_view.add_view (new StationsView ());
        });
    }

    void set_values () {
        set_focus_child (null);

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
