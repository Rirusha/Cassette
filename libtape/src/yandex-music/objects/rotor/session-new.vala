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

/**
 *
 */
public class Tape.YaMAPI.Rotor.SessionNew : Deser.DataObject {

    /**
     *
     */
    public GLib.GenericArray<string> seeds { get; set; default = new GLib.GenericArray<string> (); }

    /**
     *
     */
    public bool include_tracks_in_response { get; set; default = true; }

    /**
     *
     */
    public bool include_wave_model { get; set; default = true; }

    public override Deser.ValueCodec get_property_codec (GLib.ParamSpec property) throws Deser.Error {
        if (property.name == "seeds") return Deser.create_codec_for_array<string> ();
        return base.get_property_codec (property);
    }
}
