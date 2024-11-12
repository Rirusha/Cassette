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


public sealed class Cassette.PlayMarkTrack : PlayMarkDefault {

    construct {
        react_as_track = true;
    }

    protected override bool is_playing_now () {
        var current_track = player.mode.get_current_track_info ();

        if (current_track != null) {
            if (current_track.id == content_id) {
                return true;
            }
        }

        return false;
    }
}
