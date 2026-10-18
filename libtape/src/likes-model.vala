/*
 * Copyright (C) 2024 Vladimir Romanov
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Gee;

internal sealed class Tape.LikesModels : Object {

    HashModel _liked_tracks = new HashModel ();
    HashModel liked_tracks {
        get {
            return _liked_tracks;
        }
    }
    HashModel _liked_playlists = new HashModel ();
    HashModel liked_playlists {
        get {
            return _liked_playlists;
        }
    }
    HashModel _liked_albums = new HashModel ();
    HashModel liked_albums {
        get {
            return _liked_albums;
        }
    }
    HashModel _liked_artists = new HashModel ();
    HashModel liked_artists {
        get {
            return _liked_artists;
        }
    }

    HashModel _disliked_tracks = new HashModel ();
    HashModel disliked_tracks {
        get {
            return _disliked_tracks;
        }
    }
    HashModel _disliked_artists = new HashModel ();
    HashModel disliked_artists {
        get {
            return _disliked_artists;
        }
    }

    public void full_update (YaMAPI.Library.AllIds ids) {
        _liked_tracks.set_iterator (filter_and_map (ids.default_library, 1));
        _liked_playlists.set_iterator (filter_and_map (ids.playlists, 1));
        _liked_albums.set_iterator (filter_and_map (ids.albums, 1));
        _liked_artists.set_iterator (filter_and_map (ids.artists, 1));

        _disliked_tracks.set_iterator (filter_and_map (ids.default_library, -1));
        _disliked_artists.set_iterator (filter_and_map (ids.artists, -1));
    }

    Iterator<string> filter_and_map (Serialize.Dict<int> map, int filter_value) {
        return map.filter ((pred) => {
            return pred.value == filter_value;
        }).map<string> ((pred) => {
            return pred.key;
        });
    }
}
