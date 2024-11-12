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

namespace Cassette.Client.YaMAPI.Library {

    public class AllIds : YaMObject {

        /**
         * Лайкнутые пользователем треки
         */
        public ArrayList<string> liked_tracks { get; set; default = new ArrayList<string> (); }

        /**
         * Дизлайкнутые пользователем треки
         */
        public ArrayList<string> disliked_tracks { get; set; default = new ArrayList<string> (); }

        /**
         * Любимые исполнители пользователя
         */
        public ArrayList<string> liked_artists { get; set; default = new ArrayList<string> (); }

        /**
         * Нелюбимые исполнители пользователя
         */
        public ArrayList<string> disliked_artists { get; set; default = new ArrayList<string> (); }

        /**
         * Любимые альбомы пользователя
         */
        public ArrayList<string> albums { get; set; default = new ArrayList<string> (); }

        /**
         * Любимые плейлисты пользователя
         */
        public ArrayList<string> playlists { get; set; default = new ArrayList<string> (); }

        /**
         *
         */
        public ArrayList<string> users { get; set; default = new ArrayList<string> (); }

        /**
         * Любимые жанры пользователя
         */
        public ArrayList<string> genres { get; set; default = new ArrayList<string> (); }

        /**
         * Любимые лейблы пользователя
         */
        public ArrayList<string> labels { get; set; default = new ArrayList<string> (); }

        /**
         * Все треки в библиотеке пользователя
         */
        public ArrayList<string> library { get; set; default = new ArrayList<string> (); }
    }
}
