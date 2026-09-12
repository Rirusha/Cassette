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

namespace Tape.YaMAPI.Rotor {

    namespace ValueHeapType {
        public const string DISCRETE_SCALE = "discrete-scale";
        public const string ENUM = "enum";
    }

    namespace StationLanguage {
        public const string NOT_RUSSIAN = "not-russian";
        public const string RUSSIAN = "russian";
        public const string ANY = "any";
    }

    namespace MoodEnergy {
        public const string FUN = "fun";
        public const string ACTIVE = "active";
        public const string CALM = "calm";
        public const string SAD = "sad";
        public const string ALL = "all";
    }

    namespace Diversity {
        public const string FAVORITE = "favorite";
        public const string POPULAR = "popular";
        public const string DISCOVER = "discover";
        public const string DEFAULT = "default";
    }

    namespace FeedbackType {
        public const string RADIO_STARTED = "radioStarted";
        public const string TRACK_STARTED = "trackStarted";
        public const string SKIP = "skip";
        public const string TRACK_FINISHED = "trackFinished";
        public const string RADIO_FINISHED = "radioFinished";
        public const string LIKE = "like";
        public const string UNLIKE = "unlike";
        public const string DISLIKE = "dislike";
        public const string UNDISLIKE = "undislike";
    }

    namespace StationType {
        public const string ON_YOUR_WAVE = "user:onyourwave";
        public const string COLLECTION = "personal:collection";
    }
}

namespace Tape.YaMAPI {

    public enum PlaylistVisible {

        PUBLIC,
        PRIVATE;

        public static PlaylistVisible parse (string str) {
            switch (str) {
                case "public":
                    return PlaylistVisible.PUBLIC;

                case "private":
                    return PlaylistVisible.PRIVATE;

                default:
                    assert_not_reached ();
            }
        }

        public string to_string () {
            switch (this) {
                case PUBLIC:
                    return "public";

                case PRIVATE:
                    return "private";

                default:
                    assert_not_reached ();
            }
        }
    }

    public enum TrackType {
        MUSIC,
        AUDIOBOOK,
        PODCAST,
        LOCAL,
    }

    public enum AuthType {
        TOKEN,
        COOKIES_DB,
        COOKIES_TEXT,
    }

    public const string API_FROM = "unofficial-client-own";

    /**
     * Get api context type by object.
     *
     * @param yam_obj   object with id
     */
    public static string get_context_type (HasID yam_obj) {
        if (yam_obj is Playlist) {
            return "playlist";
        } else if (yam_obj is Album) {
            return "album";
        } else if (yam_obj is Artist) {
            return "artist";
        } else if (yam_obj is int) {
            return "search";
        } else {
            return "various";
        }
    }

    /**
     * Get api context description by object.
     *
     * @param yam_obj   object with id
     */
    public static string? get_context_description (HasID yam_obj) {
        if (yam_obj is Playlist) {
            return ((Playlist) yam_obj).title;
        } else if (yam_obj is Album) {
            return ((Album) yam_obj).title;
        } else if (yam_obj is Artist) {
            return ((Artist) yam_obj).name;
        } else {
            return null;
        }
    }

    /**
     * Get current timestamp.
     */
    public static string get_timestamp () {
        return new DateTime.now_utc ().format_iso8601 ();
    }

    /**
     * Getting the language code to send in api requests.
     * Gets the language from the system and makes a
     * "ru_RU.UTF-8" -> "ru" thing.
     *
     * @return  language code
     */
    public static string get_language () {
        string? locale = Environment.get_variable ("LANG");

        if (locale == null) {
            return "en";
        }

        if ("." in locale) {
            locale = locale.split (".")[0];
        } else if ("@" in locale) {
            locale = locale.split ("@")[0];
        }

        if ("_" in locale) {
            locale = locale.split ("_")[0];
        }

        locale = locale.down ();

        if (locale == "c") {
            return "en";
        }

        return locale;
    }
}
