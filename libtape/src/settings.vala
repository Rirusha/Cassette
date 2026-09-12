/*
 * Copyright 2024 Vladimir Romanov
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

public sealed class Tape.Settings : Object {

    /**
     * Application name.
     */
    public string app_name { get; construct; }

    public string app_name_lower {
        owned get {
            return app_name.down ();
        }
    }

    /**
     * Application ID.
     */
    public string app_id { get; construct; }

    /**
     * If `true`, the player can be controlled via mpris.
     */
    public bool can_control { get; construct; }

    /**
     * If `true`, the player can be quit via mpris.
     */
    public bool can_quit { get; construct; }

    /**
     * If `true`, the player can be raised via mpris.
     */
    public bool can_raise { get; construct; }

    /**
     * If `true`, the player can be set fullscreen via mpris.
     */
    public bool can_set_fullscreen { get; construct; }

    /**
     * Player's repeat mode. Should be used instead of `player.repat_mode`.
     */
    public RepeatMode repeat_mode { get; set; default = RepeatMode.OFF; }

    /**
     * Player's shuffle mode. Should be used instead of `player.shuffle_mode`.
     */
    public ShuffleMode shuffle_mode { get; set; default = ShuffleMode.OFF; }

    /**
     * Player's volume. Should be used instead of `player.volume`.
     */
    public double volume { get; set; default = 0.2; }

    /**
     * Player's mute. Should be used instead of `player.mute`.
     */
    public bool mute { get; set; default = false; }

    /**
     * If `true` tracks are added to the beginning of the playlist,
     * otherwise to the end.
     */
    public bool add_tracks_to_start { get; set; default = true; }

    /**
     * Download hight quality tracks or not.
     */
    public MusicQuality music_quality { get; set; default = NQ; }

    /**
     * Save content on disk or not.
     */
    public bool can_cache { get; set; default = true; }

    /**
     * Client opened in fullscreen mode or not.
     * It is NOT maximized window.
     */
    public bool fullscreen { get; set; default = false; }

    public Settings (
        string app_name,
        string app_id,
        bool can_control = true,
        bool can_quit = true,
        bool can_raise = true,
        bool can_set_fullscreen = true
    ) {
        Object (
            app_name: app_name,
            app_id: app_id,
            can_control: can_control,
            can_quit: can_quit,
            can_raise: can_raise,
            can_set_fullscreen: can_set_fullscreen
        );
    }
}
