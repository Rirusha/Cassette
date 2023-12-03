/* base_view.vala
 *
 * Copyright 2023 Rirusha
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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Cassette {
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/root_view.ui")]
    public class RootView : Adw.Bin {
        [GtkChild]
        private unowned Gtk.Stack main_stack;
        [GtkChild]
        private unowned Gtk.Spinner spinner_loading;

        public bool can_back { get; private set; default = false; }
        public bool can_refresh { get; private set; default = true; }

        private bool main_view_content_is_loaded = false;
        private bool main_view_content_is_loading = false;

        private Queue<BaseView> additional_views = new Queue<BaseView> ();

        public MainWindow window { get; construct; }
        public BaseView main_view { get; construct; }

        public RootView (MainWindow window, BaseView main_view) {
            Object (window: window, main_view: main_view);
        }

        construct {
            main_stack.add_named (main_view, "main-view");

            map.connect ((obj) => {
                if (!main_view_content_is_loaded && !main_view_content_is_loading) {
                    load_view (main_view);
                    main_view_content_is_loading = true;
                }
                can_back = false;
                window.current_view = this;
            });
            
            unmap.connect (() => {
                main_stack.visible_child = main_view;
                for (int i = 0; i < additional_views.length; i++) {
                    var elem = additional_views.pop_tail ();
                    main_stack.remove (elem);
                }
            });
        }

        public void add_view (BaseView view) {
            main_stack.add_child (view);
            load_view (view);
        }

        public void refresh () {
            var current_child = main_stack.visible_child as BaseView;
            if (current_child != null) {
                refresh_view (current_child);
                return;
            }

            var error_view = main_stack.visible_child as CantShowView;
            if (error_view != null) {
                refresh_view (error_view.base_view);
                main_stack.remove (error_view);
            }
        }

        public void backward () {
            BaseView view = additional_views.pop_tail ();
            if (additional_views.length != 0) {
                main_stack.set_visible_child (additional_views.peek_tail ());
            } else {
                main_stack.set_visible_child (main_view);
                can_back = false;
            }

            main_stack.remove (view);
        }

        void load_view (BaseView view) {
            main_stack.set_visible_child_name ("add-loading-screen");
            spinner_loading.start ();

            view.show_ready.connect(set_visible_child);
            view.root_view = this;

            view.first_show.begin ();
        }

        private void refresh_view (BaseView view) {
            main_stack.set_visible_child_name ("add-loading-screen");
            spinner_loading.start ();

            view.show_ready.connect(set_visible_child);
            view.refresh.begin ();
        }

        private void set_visible_child (BaseView view) {
            if (view == main_view) {
                main_view_content_is_loaded = true;
            } else if (additional_views.find (view).length () == 0) {
                additional_views.push_tail (view);
                can_back = true;
            }
            main_stack.set_visible_child (view);
            spinner_loading.stop ();
            view.show_ready.disconnect (set_visible_child);
            can_refresh = view.can_refresh;
        }

        public void show_error (BaseView base_view, int code) {
            if (base_view == main_view) {
                can_back = false;
            } else if (additional_views.find (base_view).length () == 0) {
                additional_views.push_tail (base_view);
                can_back = true;
            }

            var error_view = new CantShowView (base_view, code);
            main_stack.add_child (error_view);
            main_stack.set_visible_child (error_view);
        }
    }
}