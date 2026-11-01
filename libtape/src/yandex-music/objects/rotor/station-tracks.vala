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
 * YaMAPITrack list returns by `rotor` methods
 */
public class Tape.YaMAPIRotorStationTracks : Deser.DataObject {

    /**
     *
     */
    public string radio_session_id { get; set; }

    /**
     *
     */
    public GLib.GenericArray<YaMAPIRotorSequence> sequence {
        get; set;
        default = new GLib.GenericArray<YaMAPIRotorSequence> ();
    }

    /**
     *
     */
    public string batch_id { get; set; }

    /**
     * You can only think of Halloween until
     * You die
     * (by Cosmo)
     */
    public bool pumpkin { get; set; }

    /**
     *
     */
    public YaMAPIRotorSeed description_seed { get; set; }

    /**
     *
     */
    public GLib.GenericArray<YaMAPIRotorSeed> accepted_seed {
        get; set;
        default = new GLib.GenericArray<YaMAPIRotorSeed> ();
    }

    /**
     *
     */
    public YaMAPIRotorWave wave { get; set; }

    /**
     *
     */
    public bool unknown_session { get; set; }

    public override Deser.ValueCodec get_property_codec (GLib.ParamSpec property) throws Deser.Error {
        if (property.name == "sequence") return Deser.create_codec_for_array<YaMAPIRotorSequence> ();
        if (property.name == "accepted-seed") return Deser.create_codec_for_array<YaMAPIRotorSeed> ();
        return base.get_property_codec (property);
    }
}
