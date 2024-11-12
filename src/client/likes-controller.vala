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

namespace Cassette.Client {

    public enum LikableType {
        TRACK,
        PLAYLIST,
        ALBUM,
        ARTIST
    }

    public enum DislikableType {
        TRACK,
        ARTIST
    }

    // Контроллер лайков различного контента. Хранит в себе все лайки пользователя.
    public class LikesController : Object {

        HashSet<string> disliked_tracks_ids = new HashSet<string> ();
        HashSet<string> liked_tracks_ids = new HashSet<string> ();
        HashSet<string> liked_playlists_ids = new HashSet<string> ();
        HashSet<string> liked_albums_ids = new HashSet<string> ();

        public LikesController () {
            Object ();
        }

        HashSet<string> get_id_array (LikableType content_type) {
            switch (content_type) {
                case LikableType.TRACK:
                    return liked_tracks_ids;
                case LikableType.PLAYLIST:
                    return liked_playlists_ids;
                case LikableType.ALBUM:
                    return liked_albums_ids;
                default:
                    assert_not_reached ();
            }
        }

        public bool get_content_is_liked (LikableType content_type, string object_id) {
            return object_id in get_id_array (content_type);
        }

        public void update_liked_tracks (ArrayList<YaMAPI.TrackShort> track_list) {
            liked_tracks_ids.clear ();

            foreach (var track in track_list) {
                liked_tracks_ids.add (track.track.id.dup ());
            }
        }

        public void update_liked_playlists (ArrayList<YaMAPI.LikedPlaylist> playlist_list) {
            liked_playlists_ids.clear ();

            foreach (var playlist in playlist_list) {
                liked_playlists_ids.add (playlist.playlist.oid);
            }
        }

        public void update_liked_albums (ArrayList<YaMAPI.Album> album_list) {
            liked_albums_ids.clear ();

            foreach (var album in album_list) {
                liked_albums_ids.add (album.id);
            }
        }

        public void add_liked (LikableType content_type, owned string object_id) {
            get_id_array (content_type).add (object_id);
        }

        public void remove_liked (LikableType content_type, owned string object_id) {
            get_id_array (content_type).remove (object_id);
        }

        public void update_disliked_tracks (ArrayList<YaMAPI.TrackShort> track_list) {
            disliked_tracks_ids.clear ();

            foreach (var track in track_list) {
                disliked_tracks_ids.add (track.id);
            }
        }

        public void add_disliked (owned string object_id) {
            disliked_tracks_ids.add (object_id);
        }

        public void remove_disliked (owned string object_id) {
            disliked_tracks_ids.remove (object_id);
        }

        public bool get_content_is_disliked (string object_id) {
            return object_id in disliked_tracks_ids;
        }
    }
}
