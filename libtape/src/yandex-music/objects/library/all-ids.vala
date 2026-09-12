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
using Serialize;

public class Tape.YaMAPI.Library.AllIds : Serialize.DataObject {

    public Dict<int> default_library { get; set; default = new Dict<int> (); }

    public Dict<int> artists { get; set; default = new Dict<int> (); }

    public Dict<int> albums { get; set; default = new Dict<int> (); }

    public Dict<int> playlists { get; set; default = new Dict<int> (); }

    public Dict<int> users { get; set; default = new Dict<int> (); }

    public Dict<int> genres { get; set; default = new Dict<int> (); }

    public Dict<int> labels { get; set; default = new Dict<int> (); }

    public Dict<int> library { get; set; default = new Dict<int> (); }
}
