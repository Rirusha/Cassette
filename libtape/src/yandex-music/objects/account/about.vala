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
 * Account information.
 */
public class Tape.YaMAPI.Account.About : Serialize.DataObject, HasID {

    public string oid {
        owned get {
            return uid;
        }
    }

    /**
     * User id.
     */
    public string uid { get; set; }

    /**
     * Has user Yandex.Plus subscription.
     */
    public bool has_plus { get; set; default = false; }

    public bool has_music_subscription { get; set; }

    public string email { get; set; }

    public string[] options { get; set; }

    /**
     * User login.
     */
    public string login { get; set; default = ""; }

    /**
     * User avatar id.
     */
    public string? avatar_id { get; set; }

    /**
     * User login.
     */
    public string public_id { get; set; }

    /**
     * Public user name.
     */
    public string public_name { get; set; default = ""; }

    /**
     * Is user child.
     */
    public bool is_child { get; set; }

    string num_size_to_avatar_size (int size) {
        switch (size) {
            case 28:
                return "islands-small";

            case 34:
                return "islands-34";

            case 42:
                return "islands-middle";

            case 50:
                return "islands-50";

            case 56:
                return "islands-retina-small";

            case 68:
                return "islands-68";

            case 75:
                return "islands-75";

            case 84:
                return "islands-retina-middle";

            case 100:
                return "islands-retina-50";

            case 200:
                return "islands-200";

            default:
                warning ("Wrong avatar size: %d. Available values: 28, 34, 42, 50, 68, 75, 84, 100, 200", size);
                return "";
        }
    }

    public string geo_region_iso { get; set; }

    public string user_session_region_iso { get; set; }

    public bool service_available { get; set; }

    /**
     * Get avatar uri by size.
     *
     * @param size  size of avatar in pixels
     *
     * @return      avatar uri
     */
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

    public async Bytes? get_avatar (int size = 200) {
        var avatar_uri = get_avatar_uri (size);

        if (avatar_uri == null) {
            return null;
        }

        return yield root.cm.load_image_by_uri (avatar_uri, Priority.LOW);
    }
}
