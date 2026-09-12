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
 * Track list returns by `rotor` methods
 */
public class Tape.YaMAPI.Rotor.StationTracks : Serialize.DataObject {

    /**
     *
     */
    public string radio_session_id { get; set; }

    /**
     *
     */
    public Serialize.Array<Sequence> sequence { get; set; default = new Serialize.Array<Sequence> (); }

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
    public Seed description_seed { get; set; }

    /**
     *
     */
    public Serialize.Array<Seed> accepted_seed { get; set; default = new Serialize.Array<Seed> (); }

    /**
     *
     */
    public Wave wave { get; set; }

    /**
     *
     */
    public bool unknown_session { get; set; }
}
