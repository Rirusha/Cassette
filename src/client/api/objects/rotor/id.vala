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


/**
 * Класс Id станции
 */
public class Cassette.Client.YaMAPI.Rotor.Id : YaMObject {

    /**
     * Normalozation of station id.
     * type:tag
     */
    public string normal {
        owned get {
            return "%s:%s".printf (type_, tag);
        }
    }

    /**
     * Тип станции
     */
    public string type_ { get; set; }

    /**
     * Тэг станции
     */
    public string tag { get; set; }
}
