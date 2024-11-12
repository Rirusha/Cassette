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


public class Cassette.PageRoot : AbstractLoadablePage {

    public bool can_back { get; private set; default = false; }
    public bool can_refresh { get; private set; default = true; }

    bool main_view_is_loaded = false;

    public Window window { get; construct; }
    public BaseView main_view { get; construct; }

    public Gtk.Widget current_widget {
        get {
            return nav_view.visible_page.child;
        }
    }

    public PageRoot (Window window, BaseView main_view) {
        Object (window: window, main_view: main_view, with_header_bar: false);
    }

    construct {
        nav_view.add (new Adw.NavigationPage.with_tag (main_view, "title", "main-view"));
        main_view.root_view = this;

        nav_view.notify["visible-page"].connect (() => {
            if (current_widget == main_view) {
                can_back = false;
            }

            if (current_widget is BaseView) {
                can_refresh = ((BaseView) current_widget).can_refresh;
            }
        });

        notify["is-loading"].connect (() => {
            can_back = !is_loading && can_back;
            can_refresh = !is_loading && can_refresh;
        });

        map.connect (() => {
            if (!main_view_is_loaded) {
                load_view (main_view);
            }

            window.current_view = this;
        });

        unmap.connect (() => {
            if (main_view_is_loaded && !is_loading) {
                nav_view.pop_to_tag ("main-view");
            }
        });
    }

    public void add_view (BaseView view) {
        nav_view.push (new Adw.NavigationPage (view, "title"));
        view.root_view = this;
        load_view (view);
    }

    public void refresh () {
        var current_child = current_widget as BaseView;
        if (current_child != null) {
            refresh_view (current_child);
            return;
        }

        var error_view = current_widget as CantShowView;
        if (error_view != null) {
            nav_view.pop ();
            add_view (error_view.base_view);
        }
    }

    public void backward () {
        nav_view.pop ();
    }

    void load_view (BaseView view) {
        start_loading ();

        view.show_ready.connect (show_view);
        view.first_show.begin ();
    }

    void refresh_view (BaseView view) {
        start_loading ();

        view.show_ready.connect (show_view);
        view.refresh.begin ();
    }

    void show_view (BaseView view) {
        stop_loading ();
        view.show_ready.disconnect (show_view);

        can_refresh = view.can_refresh;

        if (view == main_view) {
            main_view_is_loaded = true;

        } else {
            can_back = true;
        }
    }

    public void show_error (BaseView base_view, int code) {
        stop_loading ();
        base_view.show_ready.disconnect (show_view);
        nav_view.pop ();

        nav_view.push (new Adw.NavigationPage (
            new CantShowView (base_view, code),
            "title"
        ));

        can_refresh = true;

        if (base_view == main_view) {
            can_back = false;

        } else {
            can_back = true;
        }
    }
}
