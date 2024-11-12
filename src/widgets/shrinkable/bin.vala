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


/*
 * Connection for ``Cassette.ApplicationWindow`` resize
 * for different shrink edge width. Allow connect secure connect
 * with `Cassette.ApplicationWindow::is-shrinked` with
 * `Cassete.ShrinkableBin::root-window-is-shrinked`
 * Used for all adaptive things.
 */
public class Cassette.ShrinkableBin : Adw.Bin {

    /**
     * Size changed.
     *
     * @param width     new width of window
     * @param height    new height of window
     */
    public signal void resized (int width, int height);

    /**
     * Width value, that triggers ``is-shrinked`` changes
     */
    public int shrink_edge_width { get; set; default = -1; }

    public bool root_window_is_shrinked { get; private set; default = false; }

    /**
     * Is widget should shrinked or not
     */
    public bool is_shrinked { get; private set; default = false; }

    bool first_resize = true;

    construct {
        if (application.main_window != null) {
            connect_to_main_window ();
        } else {
            application.notify["main-window"].connect (on_application_window_notify);
        }
    }

    void on_application_window_notify () {
        if (application.main_window != null) {
            connect_to_main_window ();
            application.notify["main-window"].disconnect (on_application_window_notify);
        }
    }

    void connect_to_main_window () {
        application.main_window.resized.connect (on_resized);

        application.main_window.notify["is-shrinked"].connect (() => {
            root_window_is_shrinked = application.main_window.is_shrinked;
        });
        root_window_is_shrinked = application.main_window.is_shrinked;
    }

    void on_resized (int width, int height) {
        if (shrink_edge_width != -1) {
            if (width >= shrink_edge_width) {
                if (is_shrinked || first_resize) {
                    is_shrinked = false;
                }
            } else {
                if (!is_shrinked || first_resize) {
                    is_shrinked = true;
                }
            }

            first_resize = false;
        }

        resized (width, height);
    }
}
