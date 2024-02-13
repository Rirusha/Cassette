/* Copyright 2023-2024 Rirusha
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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


using Gee;

namespace CassetteClient.YaMAPI.Rotor {
    public class StationTracks : YaMObject {

        public Id id { get; set; }
        public ArrayList<Sequence> sequence { get; set; default = new ArrayList<Sequence> (); }
        public string batch_id { get; set; }
        public bool pumpkin { get; set; }
        public string radio_session_id { get; set; }
    }
}
