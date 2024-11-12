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


namespace Cassette {

    public class LoadingPage : Adw.NavigationPage {

        private LoadingSpinner _loading_widget = new LoadingSpinner () { size = 32 };
        public LoadingSpinner loading_widget {
            get {
                return _loading_widget;
            }
        }

        public bool with_header_bar { get; construct set; }

        public LoadingPage (bool with_header_bar) {
            Object (with_header_bar: with_header_bar);
        }

        construct {
            title = _("Loading…");
            can_pop = false;

            if (with_header_bar) {
                var header_bar = new Adw.HeaderBar () {
                    show_back_button = false,
                    show_end_title_buttons = false
                };

                var toolbar_view = new Adw.ToolbarView ();
                toolbar_view.add_top_bar (header_bar);
                toolbar_view.content = _loading_widget;

                child = toolbar_view;

            } else {
                child = _loading_widget;
            }
        }
    }
}
