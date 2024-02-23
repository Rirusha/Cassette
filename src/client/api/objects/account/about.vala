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


namespace Cassette.Client.YaMAPI.Account {

    namespace AvatarSize {
        const string ISLANDS_SMALL = "islands-small";
        const string ISLANDS_34 = "islands-34";
        const string ISLANDS_MIDDLE = "islands-middle";
        const string ISLANDS_50 = "islands-50";
        const string ISLANDS_RETINA_SMALL = "islands-retina-small";
        const string ISLANDS_68 = "islands-68";
        const string ISLANDS_75 = "islands-75";
        const string ISLANDS_RETINA_MIDDLE = "islands-retina-middle";
        const string ISLANDS_RETINA_50 = "islands-retina-50";
        const string ISLANDS_200 = "islands-200";
    }

    public class About : YaMObject {

        /*
         * Id пользователя
         */
        public string uid { get; set; }

        /*
         * Имеет ли пользователь активную подписку Я.Плюс
         */
        public bool has_plus { get; set; }

        /*
         * Логин пользователя
         */
        public string login { get; set; }

        /*
         * Id аватара пользователя
         */
        public string? avatar_id { get; set; }

        /*
         * TODO
         */
        public string public_id { get; set; }

        /*
         * Публичное имя пользователя
         */
        public string public_name { get; set; }

        /*
         * Является ли аккаунт детским
         */
        public bool is_child { get; set; }

        public static string num_size_to_avatar_size (int size) {
            switch (size) {
                case 28:
                    return AvatarSize.ISLANDS_SMALL;
                case 34:
                    return AvatarSize.ISLANDS_34;
                case 42:
                    return AvatarSize.ISLANDS_MIDDLE;
                case 50:
                    return AvatarSize.ISLANDS_50;
                case 56:
                    return AvatarSize.ISLANDS_RETINA_SMALL;
                case 68:
                    return AvatarSize.ISLANDS_68;
                case 75:
                    return AvatarSize.ISLANDS_75;
                case 84:
                    return AvatarSize.ISLANDS_RETINA_MIDDLE;
                case 100:
                    return AvatarSize.ISLANDS_RETINA_50;
                case 200:
                    return AvatarSize.ISLANDS_200;
                default:
                    assert_not_reached ();
            }
        }

        public string? get_avatar_uri (int size = 200) {
            if (avatar_id == null) {
                return null;
            }

            var avatar_size = num_size_to_avatar_size (size);

            return "https://avatars.yandex.net/get-yapic/%s/%s".printf (
                avatar_id,
                avatar_size
            );
        }
    }
}
