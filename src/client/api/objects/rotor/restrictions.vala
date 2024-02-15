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


namespace CassetteClient.YaMAPI.Rotor {
    public class Restrictions : YaMObject {

        public Enum language { get; set; }
        public Enum diversity { get; set; }
        public DiscreteScale mood { get; set; }
        public DiscreteScale energy { get; set; }
        public Enum mood_energy { get; set; }
    }
}
