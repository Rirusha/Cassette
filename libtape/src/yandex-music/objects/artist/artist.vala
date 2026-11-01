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

public class Tape.YaMAPI.Artist : Deser.DataObject, HasID {

    public string oid {
        owned get {
            return id;
        }
    }

    public string id { get; set; }

    public string? reason { get; set; }

    public string? name { get; set; }

    public Cover? cover { get; set; }

    public bool various { get; set; }

    public bool composer { get; set; }

    public GLib.GenericArray<string> genres { get; set; default = new GLib.GenericArray<string> (); }

    public Counts? counts { get; set; }

    public bool is_available { get; set; }

    public Ratings? ratings { get; set; }

    public GLib.GenericArray<Link> links { get; set; default = new GLib.GenericArray<Link> (); }

    public int likes_count { get; set; }

    public GLib.GenericArray<Track> popular_tracks { get; set; default = new GLib.GenericArray<Track> (); }

    public string? hand_made_description { get; set; }

    public string? description { get; set; }

    public GLib.GenericArray<string> countries { get; set; default = new GLib.GenericArray<string> (); }

    public string? en_wikipedia_link { get; set; }

    public string? ya_money_id { get; set; }

    public GLib.GenericArray<string> get_cover_items_by_size (int size) {
        GLib.GenericArray<string> cover_array = new GLib.GenericArray<string> ();

        if (cover == null) {
            return cover_array;
        }

        cover_array.add ("https://" + cover.items_uri[0].replace ("%%", @"$(size)x$(size)"));

        return cover_array;
    }

    public override Deser.ValueCodec get_property_codec (GLib.ParamSpec property) throws Deser.Error {
        if (property.name == "genres") return Deser.create_codec_for_array<string> ();
        if (property.name == "links") return Deser.create_codec_for_array<Link> ();
        if (property.name == "popular-tracks") return Deser.create_codec_for_array<Track> ();
        if (property.name == "countries") return Deser.create_codec_for_array<string> ();
        return base.get_property_codec (property);
    }
}
