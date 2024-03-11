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


namespace Cassette.Client.YaMAPI.Rotor {

    /**
     * Информация о станции
     */
    public class Station : YaMObject {

        /**
         * Station id. Doesn't work with ``_dashboard`` and ``_list`` rotor methods
         */
        public string station_id { get; set; }

        /**
         * Station object. Using with ``_dashboard`` and ``_list`` rotor methods
         */
        public StationInfo station { get; set; }

        /**
         * Название станции
         */
        public string title { get; set; }

        /**
         * TODO
         */
        public string rup_title { get; set; }

        /**
         * TODO
         */
        public string rup_description { get; set; }
    }
}
