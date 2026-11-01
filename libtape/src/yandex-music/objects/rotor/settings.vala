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
 * Wave settings.
 */
public class Tape.YaMAPI.Rotor.Settings : Deser.DataObject {

    /**
     *
     */
    public Station default_station { get; set; }

    /**
     *
     */
    public GLib.GenericArray<Block> blocks { get; set; default = new GLib.GenericArray<Block> (); }

    /**
     *
     */
    public Restrictions setting_restrictions { get; set; }

    public override Deser.ValueCodec get_property_codec (GLib.ParamSpec property) throws Deser.Error {
        if (property.name == "blocks") return Deser.create_codec_for_array<Block> ();
        return base.get_property_codec (property);
    }
}
