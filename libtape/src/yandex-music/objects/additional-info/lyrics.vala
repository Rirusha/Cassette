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

public class Tape.YaMAPILyrics : Deser.DataObject {

    public string download_url { get; set; }

    public int lyric_id { get; set; }

    public string? external_lyric_id { get; set; }

    public GLib.GenericArray<string> writers { get; set; default = new GLib.GenericArray<string> (); }

    public YaMAPILyricsMajor? major { get; set; }

    public GLib.GenericArray<string> text { get; set; default = new GLib.GenericArray<string> (); }

    public bool is_sync { get; set; }

    public string get_writers_names () {
        string[] names = new string[writers.length];
        for (uint i = 0; i < writers.length; i++) names[i] = writers[i];
        return string.joinv (", ", names);
    }

    public override Deser.ValueCodec get_property_codec (GLib.ParamSpec property) throws Deser.Error {
        if (property.name == "writers") return Deser.create_codec_for_array<string> ();
        if (property.name == "text") return Deser.create_codec_for_array<string> ();
        return base.get_property_codec (property);
    }
}
