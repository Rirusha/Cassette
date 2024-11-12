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

using Gee;

namespace Cassette.Client.YaMAPI {

    /**
     * Датакласс короткого преставления трека.
     */
    public class TrackShort : YaMObject {

        /**
         * Id трека.
         */
        public string id { get; set; }

        /**
         * Объект трека.
         */
        public Track? track { get; set; }

        /**
         *
         */
        public int original_index { get; set; }

        /**
         *
         */
        public int original_shuffle_index { get; set; }

        /**
         * Временная метка.
         */
        public string timestamp { get; set; }
    }
}
