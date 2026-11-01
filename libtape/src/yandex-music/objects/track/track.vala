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

public class Tape.YaMAPI.Track : Deser.DataObject, HasCover {

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
            foreach (var option in available_for_options) {
                if (option == "bookmate") return true;
            }
            return false;
        }
    }

    public string id { get; set; }

    public string? title { get; set; }

    public bool available { get; set; }

    public GLib.GenericArray<Artist> artists { get; set; default = new GLib.GenericArray<Artist> (); }

    public GLib.GenericArray<Album> albums { get; set; default = new GLib.GenericArray<Album> (); }

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

    public GLib.GenericArray<string> available_for_options { get; set; default = new GLib.GenericArray<string> (); }

    public LyricsInfo lyrics_info { get; set; }

    public virtual GLib.GenericArray<string> get_cover_items_by_size (int size) {
        var array = new GLib.GenericArray<string> ();
        if (cover_uri != null) {
            array.add ("https://" + cover_uri.replace ("%%", @"$(size)x$(size)"));
        }
        return array;
    }

    public string get_artists_names () {
        var artists_names = new string[artists.length];
        for (int i = 0; i < artists.length; i++) {
            artists_names[i] = artists[i].name;
        }
        return string.joinv (", ", artists_names);
    }

    public string get_album_title () {
        string album_title;

        if (albums.length != 0) {
            album_title = albums[0].title;
        } else {
            album_title = meta_data ? .album;
        }

        return album_title != null ? album_title : "Unknown Album";
    }

    public override Deser.ValueCodec get_property_codec (GLib.ParamSpec property) throws Deser.Error {
        if (property.name == "artists") return Deser.create_codec_for_array<Artist> ();
        if (property.name == "albums") return Deser.create_codec_for_array<Album> ();
        if (property.name == "available-for-options") return Deser.create_codec_for_array<string> ();
        return base.get_property_codec (property);
    }
}
