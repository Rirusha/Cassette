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

public class Tape.AccountSettings : Deser.DataObject {

    public bool add_new_track_on_playlist_top { get; set; }

    public bool ads_disabled { get; set; }

    public bool ai_content_reduction_enabled { get; set; }

    public bool auto_play_radio { get; set; }

    public bool child_mode_enabled { get; set; }

    public bool child_mode_changed_by_user { get; set; }

    public bool explicit_forbidden { get; set; }

    public bool facebook_scrobbling_enabled { get; set; }

    public bool last_fm_scrobbling_enabled { get; set; }

    public DateTime modified { get; set; }

    public bool promos_disabled { get; set; }

    public bool rbt_disabled { get; set; }

    public bool shuffle_enabled { get; set; }

    public bool sync_queue_enabled { get; set; }

    public string theme { get; set; }

    public int64 uid { get; set; }

    public int user_collection_hue { get; set; }

    public string user_music_visibility { get; set; }

    public string user_social_visibility { get; set; }

    public int volume_percents { get; set; }

    public bool wizard_is_passed { get; set; }
}
