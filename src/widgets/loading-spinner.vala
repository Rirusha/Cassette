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

    public class LoadingSpinner : Adw.Bin {
        /**
            Виджет для избавления от повторяющегося кода и автоматизации
            начала и завершении анимации загрузки
        */

        public int size {
            get {
                return width_request;
            }
            set {
                width_request = value;
                height_request = value;
            }
        }

        private Gtk.Spinner spinner = new Gtk.Spinner ();

        public LoadingSpinner () {
            Object ();
        }

        construct {
            child = spinner;

            vexpand = true;
            hexpand = true;
            valign = Gtk.Align.CENTER;
            halign = Gtk.Align.CENTER;

            map.connect (() => {
                spinner.start ();
            });
            unmap.connect (() => {
                spinner.stop ();
            });
        }
    }
}
