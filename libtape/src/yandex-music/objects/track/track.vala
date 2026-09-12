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

public class Tape.YaMAPI.Track : Serialize.DataObject, HasCover {

    public bool is_explicit {
        get {
            return content_warning == "explicit" ? true : false;
        }
    }

    public bool is_ugc {
        get {
            return track_source == "UGC" ? true : false;
        }
    }

    public string track_id {
        get {
            return id;
        }
        set {
            id = value;
        }
    }

    public string title_with_version {
        owned get {
            if (version != null) {
                return @"$title $version";
            }
            return title;
        }
    }

    public TrackType track_type {
        get {
            switch (type_) {
                case "audiobook":
                    return TrackType.AUDIOBOOK;

                case "podcast-episode":
                    return TrackType.PODCAST;

                case "local":
                    return TrackType.LOCAL;

                default:
                    return TrackType.MUSIC;
            }
        }
    }

    public bool need_bookmate {
        get {
            return "bookmate" in available_for_options;
        }
    }

    public string id { get; set; }

    public string? title { get; set; }

    public bool available { get; set; }

    public Serialize.Array<Artist> artists { get; set; default = new Serialize.Array<Artist> (); }

    public Serialize.Array<Album> albums { get; set; default = new Serialize.Array<Album> (); }

    public bool available_for_premium_users { get; set; }

    public bool lyrics_available { get; set; }

    public string? cover_uri { get; set; }

    public Label major { get; set; }

    public int64 duration_ms { get; set; }

    public Track? substituted { get; set; }

    public MetaData? meta_data { get; set; }

    [Description (nick = "type")]
    public string? type_ { get; set; }

    public string? content_warning { get; set; }

    public string? version { get; set; }

    public string? short_description { get; set; }

    public bool is_suitable_for_children { get; set; }

    public string track_source { get; set; }

    public Serialize.Array<string> available_for_options { get; set; default = new Serialize.Array<string> (); }

    public LyricsInfo lyrics_info { get; set; }

    public virtual Serialize.Array<string> get_cover_items_by_size (int size) {
        var array = new Serialize.Array<string> ();
        if (cover_uri != null) {
            array.add ("https://" + cover_uri.replace ("%%", @"$(size)x$(size)"));
        }
        return array;
    }

    public string get_artists_names () {
        var artists_names = new string[artists.size];
        for (int i = 0; i < artists.size; i++) {
            artists_names[i] = artists[i].name;
        }
        return string.joinv (", ", artists_names);
    }

    public string get_album_title () {
        string album_title;

        if (!albums.is_empty) {
            album_title = albums[0].title;
        } else {
            album_title = meta_data ? .album;
        }

        return album_title != null ? album_title : "Unknown Album";
    }
}
