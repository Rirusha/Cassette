/* player_flow.vala
 *
 * Copyright 2023 Rirusha
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

namespace CassetteClient.Player {
    public class PlayerFL: Object, IPlayerMod {

        public YaMAPI.Track? current_track {
            owned get {
                return null;
            }
        }
        public YaMAPI.Track next_track {
            owned get {
                return new YaMAPI.Track ();
            }
        }
        public YaMAPI.Track prev_track {
            owned get {
                return new YaMAPI.Track ();
            }
        }

        public PlayerFL () {
            Object ();
        }

        public void next (bool consider_repeat_mode) {

        }

        public void prev () {

        }
    }
}