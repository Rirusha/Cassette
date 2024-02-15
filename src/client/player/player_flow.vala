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

using Gee;

namespace CassetteClient.Player {
    public class PlayerFlow : PlayerMode {

        public Player player { get; construct; }

        public PlayerFlow (Player player) {
            Object (player: player);
        }

        public async override YaMAPI.Track? get_prev_track () {
            assert_not_reached ();
        }

        public override YaMAPI.Track? get_current_track () {
            assert_not_reached ();
        }

        public async override YaMAPI.Track? get_next_track () {
            assert_not_reached ();
        }

        public override void next (bool consider_repeat_mode) {
            assert_not_reached ();
        }

        public override void prev () {
            assert_not_reached ();
        }
    }
}
