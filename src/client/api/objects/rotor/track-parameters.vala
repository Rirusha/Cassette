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


/**
 * Track parameters object
 */
public class Cassette.Client.YaMAPI.Rotor.TrackParameters : YaMObject {

    /**
     * Bits per minutes.
     */
    public int bpm { get; set; }

    /**
     * Track color in hue.
     */
    public int hue { get; set; }

    /**
     * Intensivity of track energy.
     */
    public double energy { get; set; }
}
