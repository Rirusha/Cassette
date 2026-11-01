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

/**
 *
 */
public class Tape.YaMAPIRotorStation : Deser.DataObject {

    /**
     * YaMAPIRotorStation id. Doesn't work with `_dashboard` and `_list` rotor methods
     */
    public string station_id { get; set; }

    /**
     * YaMAPIRotorStation object. Using with `_dashboard` and `_list` rotor methods
     */
    public YaMAPIRotorStationInfo station { get; set; }

    /**
     * YaMAPIRotorStation title
     */
    public string title { get; set; }

    /**
     *
     */
    public string rup_title { get; set; }

    /**
     *
     */
    public string rup_description { get; set; }
}
