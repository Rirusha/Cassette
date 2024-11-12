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

    public abstract class AbstractLoadablePage : Adw.Bin {
        public Adw.NavigationView nav_view { get; set; default = new Adw.NavigationView (); }
        public bool with_header_bar { get; construct; }

        public LoadingPage loading_page { get; private set; }

        public bool is_loading { get; private set; }

        construct {
            loading_page = new LoadingPage (with_header_bar);

            child = nav_view;

            nav_view.animate_transitions = false;
        }

        public void start_loading () {
            assert (is_loading == false);
            assert (nav_view != null);

            is_loading = true;

            nav_view.animate_transitions = false;
            nav_view.push (loading_page);
        }

        public void stop_loading () {
            assert (is_loading == true);
            assert (nav_view != null);

            nav_view.pop ();
            nav_view.animate_transitions = false;

            is_loading = false;
        }
    }
}
