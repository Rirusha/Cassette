/* track_row_content.vala
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


using CassetteClient;


namespace Cassette {
    public abstract class YATrackRowContent : TrackRowContent {

        public HasTrackList yam_object { get; construct; }

        public async void remove_from_playlist_async () {
            var playlist = (YaMAPI.Playlist) yam_object;

            int position = -1;
            for (int i = 0; i < playlist.tracks.size; i++) {
                if (track_info.id == playlist.tracks[i].id) {
                    position = i;
                    break;
                }
            }

            threader.add (() => {
                yam_talker.remove_tracks_from_playlist (playlist.kind, position, playlist.revision);

                Idle.add (remove_from_playlist_async.callback);
            });

            yield;
        }
    }
}