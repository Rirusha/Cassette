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


namespace CassetteClient.YaMAPI {
    public class LikesData : YaMObject {
        /*
            Объект для хранения блоков с информацией о лайках/дизлайках
            различных сущностей
        */

        public LikesBlock default_library { get; default = new LikesBlock (); }
        public LikesBlock artists { get; default = new LikesBlock (); }
        public LikesBlock albums { get; default = new LikesBlock (); }
        public LikesBlock playlists { get; default = new LikesBlock (); }
        public LikesBlock users { get; default = new LikesBlock (); }
        public LikesBlock genres { get; default = new LikesBlock (); }
        public LikesBlock labels { get; default = new LikesBlock (); }
        public LikesBlock library { get; default = new LikesBlock (); }
    }
}
