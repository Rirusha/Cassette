/* Copyright 2023-2024 Vladimir Vaskov
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */


using Gee;

/**
 * Dashboard with user stations
 */
public class Cassette.Client.YaMAPI.Rotor.Dashboard : YaMObject {

    /**
     * Dashboard id
     */
    public string dashboard_id { get; set; }

    /**
     * Station list
     */
    public ArrayList<Station> stations { get; set; default = new ArrayList<Station> (); }

    /**
     * You can only think of Halloween until
     * You die
     * (by Cosmo)
     */
    public bool pumpkin { get; set; }
}
