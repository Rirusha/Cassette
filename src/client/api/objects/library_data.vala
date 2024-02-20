/* Copyright 2023-2024 Rirusha
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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */


using Gee;

namespace CassetteClient.YaMAPI {
    public class LibraryData : YaMObject {
        /*
            Объект для хранения блоков с информацией о лайках/дизлайках
            различных сущностей
        */

        public ArrayList<string> liked_tracks { get; set; default = new ArrayList<string> (); }
        public ArrayList<string> disliked_tracks { get; set; default = new ArrayList<string> (); }
        public ArrayList<string> artists { get; set; default = new ArrayList<string> (); }
        public ArrayList<string> albums { get; set; default = new ArrayList<string> (); }
        public ArrayList<string> playlists { get; set; default = new ArrayList<string> (); }
        public ArrayList<string> users { get; set; default = new ArrayList<string> (); }
        public ArrayList<string> genres { get; set; default = new ArrayList<string> (); }
        public ArrayList<string> labels { get; set; default = new ArrayList<string> (); }
        public ArrayList<string> library { get; set; default = new ArrayList<string> (); }
    }
}
