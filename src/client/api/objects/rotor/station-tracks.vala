/* Copyright 2023-2024 Vladimir Vaskov
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


using Gee;

/**
 * Track list returns by ``rotor`` methods
 */
public class Cassette.Client.YaMAPI.Rotor.StationTracks : YaMObject {

    /**
     *
     */
    public string radio_session_id { get; set; }

    /**
     *
     */
    public ArrayList<Sequence> sequence { get; set; default = new ArrayList<Sequence> (); }

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
    public ArrayList<Seed> accepted_seed { get; set; default = new ArrayList<Seed> (); }

    /**
     *
     */
    public Wave wave { get; set; }

    /**
     *
     */
    public bool unknown_session { get; set; }
}
