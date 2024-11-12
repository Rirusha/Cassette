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

namespace Cassette.Client.YaMAPI.Rotor {

    namespace ValueHeapType {
        public const string DISCRETE_SCALE = "discrete-scale";
        public const string ENUM = "enum";
    }

    /**
     * Value heap in api.
     * Discrete scale or enum
     */
    public class ValueHeap : YaMObject {

        /**
         * Data type.
         * Can be: 'discrete-scale', 'enum'.
         */
        public string type_ { get; set; }

        /**
         * Название кучи.
         */
        public string name { get; set; }

        /**
         * Possible values (for 'enum').
         */
        public ArrayList<Rotor.Value> possible_values { get; set; default = new ArrayList<Rotor.Value> (); }

        /**
         * Minimum value. (for 'discrete-scale')
         */
        public Rotor.Value min { get; set; }

        /**
         * Maximum value. (for 'discrete-scale')
         */
        public Rotor.Value max { get; set; }
    }
}
