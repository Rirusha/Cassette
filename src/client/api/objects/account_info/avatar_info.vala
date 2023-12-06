/* account_info.vala
 *
 * Copyright 2023 Rirusha
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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace CassetteClient.YaMAPI {
    public enum AvatarSize {
        ISLANDS_SMALL = 28,
        ISLANDS_34 = 34,
        ISLANDS_MIDDLE = 42,
        ISLANDS_50 = 50,
        ISLANDS_RETINA_SMALL = 56,
        ISLANDS_68 = 68,
        ISLANDS_75 = 75,
        ISLANDS_RETINA_MIDDLE = 84,
        ISLANDS_RETINA_50 = 100,
        ISLANDS_200 = 200
    }

    public class AvatarInfo : YaMObject {

        public string? default_avatar_id { get; set; }
        public bool is_avatar_empty { get; set; }

        public AvatarInfo () {
            Object ();
        }

        public string? get_avatar_uri (int size = 200) {
            if (is_avatar_empty) {
                return null;
            }

            var asize = (AvatarSize) size;

            //  CASSETTE_CLIENT_YA_MAPI_AVATAR_SIZE_ISLANDS_200 -> islands-200
            string size_str = snake2kebab (asize.to_string ()[36:].down ());

            return @"https://avatars.yandex.net/get-yapic/$default_avatar_id/$size_str";
        }
    }
}
