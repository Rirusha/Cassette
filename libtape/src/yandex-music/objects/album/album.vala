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

public class Tape.YaMAPI.Album : Deser.DataObject, HasCover, HasID {

    public string oid {
        owned get {
            return id;
        }
    }

    public bool explicit {
        get {
            return content_warning == "explicit" ? true : false;
        }
    }

    public string id { get; set; }

    public string title { get; set; }

    public int track_count { get; set; }

    public GLib.GenericArray<Artist> artists { get; set; default = new GLib.GenericArray<Artist> (); }

    public GLib.GenericArray<Label> labels { get; set; default = new GLib.GenericArray<Label> (); }

    public bool available { get; set; }

    public string? version { get; set; }

    public string? cover_uri { get; set; }

    public string? content_warning { get; set; }

    public string? genre { get; set; }

    public string? short_description { get; set; }

    public string? description { get; set; }

    public bool is_premiere { get; set; }

    public bool is_banner { get; set; }

    public bool recent { get; set; }

    public bool very_important { get; set; }

    public GLib.GenericArray<int> bests { get; set; default = new GLib.GenericArray<int> (); }

    public GLib.GenericArray<Album> duplicates { get; set; default = new GLib.GenericArray<Album> (); }

    public GLib.GenericArray<GLib.GenericArray<Track> > volumes {
        get; set;
        default = new GLib.GenericArray<GLib.GenericArray<Track> > ();
    }

    public int year { get; set; }

    public string? release_date { get; set; }

    public GLib.GenericArray<Album> albums { get; set; default = new GLib.GenericArray<Album> (); }

    public int duration_ms { get; set; }

    public int likes_count { get; set; }

    construct {
        volumes.add (new GLib.GenericArray<Track> ());
    }

    public GLib.GenericArray<string> get_cover_items_by_size (int size) {
        GLib.GenericArray<string> cover_array = new GLib.GenericArray<string> ();

        if (cover_uri == null) {
            return cover_array;
        }

        cover_array.add ("https://" + cover_uri.replace ("%%", @"$(size)x$(size)"));

        return cover_array;
    }

    public override Deser.ValueCodec get_property_codec (GLib.ParamSpec property) throws Deser.Error {
        if (property.name == "artists") return Deser.create_codec_for_array<Artist> ();
        if (property.name == "labels") return Deser.create_codec_for_array<Label> ();
        if (property.name == "bests") return Deser.create_codec_for_array<int> ();
        if (property.name == "duplicates") return Deser.create_codec_for_array<Album> ();
        if (property.name == "volumes") {
            return new Deser.GenericArrayCodec<GLib.GenericArray<Track>> (
                Deser.create_codec_for_array<Track> ()
            );
        }
        if (property.name == "albums") return Deser.create_codec_for_array<Album> ();
        return base.get_property_codec (property);
    }
}
