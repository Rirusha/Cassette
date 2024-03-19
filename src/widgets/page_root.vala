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


public class Cassette.PageRoot : AbstractLoadablePage {

    public bool can_back { get; private set; default = false; }
    public bool can_refresh { get; private set; default = true; }

    bool main_view_is_loaded = false;

    public MainWindow window { get; construct; }
    public BaseView main_view { get; construct; }

    public Gtk.Widget current_widget {
        get {
            return nav_view.visible_page.child;
        }
    }

    public PageRoot (MainWindow window, BaseView main_view) {
        Object (window: window, main_view: main_view, with_header_bar: false);
    }

    construct {
        nav_view.add (new Adw.NavigationPage.with_tag (main_view, "title", "main-view"));
        main_view.root_view = this;
        load_view (main_view);

        notify["is-loading"].connect (() => {
            can_back = !is_loading && can_back;
        });

        map.connect (() => {
            //  if (main_view_is_loaded) {
            //      nav_view.push_by_tag ("main-view");
            //      can_back = false;
            //  }

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
            refresh_view (error_view.base_view);
        }
    }

    public void backward () {
        nav_view.pop ();

        if (current_widget == main_view) {
            can_back = false;
        }

        //  BaseView view = additional_views.pop_tail ();
        //  if (additional_views.length != 0) {
        //      main_stack.set_visible_child (additional_views.peek_tail ());
        //  } else {
        //      main_stack.set_visible_child (main_view);
        //      can_back = false;
        //  }

        //  main_stack.remove (view);
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
        if (view == main_view) {
            main_view_is_loaded = true;

        } else {
            can_back = true;
        }

        //  else if (nav_view.find_page (string tag)) {
        //      additional_views.push_tail (view);
        //      can_back = true;
        //  }

        stop_loading ();
        view.show_ready.disconnect (show_view);

        //  main_stack.set_visible_child (view);
        //  spinner_loading.stop ();

        can_refresh = view.can_refresh;
    }

    public void show_error (BaseView base_view, int code) {
        if (base_view == main_view) {
            can_back = false;

        } else {
            can_back = true;
        }

        stop_loading ();
        base_view.show_ready.disconnect (show_view);

        var error_view = new CantShowView (base_view, code);

        nav_view.pop ();
        nav_view.push (new Adw.NavigationPage (error_view, "title"));
    }
}
