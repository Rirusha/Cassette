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


using CassetteClient;
using WebKit;


namespace Cassette {

    public class BeginWindow : Adw.Window {
        private BeginView _begin_view = new BeginView (true);
        public BeginView begin_view {
            get {
                return _begin_view;
            }
        }

        public BeginWindow () {
            Object ();
        }

        construct {
            content = begin_view;

            default_width = 600;
            default_height = 960;

            modal = true;

            begin_view.online_complete.connect (close);
            begin_view.local_choosed.connect (close);
        }
    }
}
