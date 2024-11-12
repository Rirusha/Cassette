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

    public abstract class PlayButtonDefault : PlayButton, Initable {

        public signal void clicked_not_playing ();

        protected string content_id { get; set; }

        construct {
            real_button.clicked.connect (button_clicked);
        }

        public void init_content (string content_id) {
            this.content_id = content_id;

            post_init ();
        }

        protected abstract void post_init ();

        public void button_clicked () {
            if (on_clicked ()) {
                clicked_not_playing ();
            }
        }

        // Возвращает true, если можно продолжать действия и false, если нельзя
        protected abstract bool on_clicked ();
    }
}
