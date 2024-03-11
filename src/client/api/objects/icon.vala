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


namespace Cassette.Client.YaMAPI {

    /**
     * Класс иконки
     */
    public class Icon : YaMObject {

        /**
         * Цвет заднего фона в HEX
         */
        public string background_color { get; set; }

        /**
         * Ссылка на иконку
         */
        public string image_url { get; set; }

        public static string get_internal_icon_name (string station_id) {
            switch (station_id) {
                default:
                    Logger.warning ("Unknown icon \"%s\" with url \"%s\"".printf (ya_icon_name, image_url));

                    return "io.github.Rirusha.Cassette-symbolic";
            }
        }
    }
}
