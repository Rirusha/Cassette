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


using Cassette.Client;


namespace Cassette {
    public abstract class YATrackRowContent : TrackRow {

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
