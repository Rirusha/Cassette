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
     * TODO
     */
    public class StationInfo : YaMObject {

        /**
         * TODO
         */
        public Id id { get; set; }

        /**
         * TODO
         */
        public string name { get; set; }

        /**
         * TODO
         */
        public Icon icon { get; set; }

        /**
         * TODO
         */
        public string full_image_url { get; set; }

        /**
         * TODO
         */
        [Version (deprecated = true)]
        public Restrictions restrictions { get; set; }

        /**
         * TODO
         */
        public Restrictions restrictions2 { get; set; }

        /**
         * TODO
         */
        public bool special_context { get; set; }
    }
}
