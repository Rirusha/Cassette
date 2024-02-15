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


namespace CassetteClient.YaMAPI.Rotor {
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

    public class Settings : YaMObject {

        public string language { get; set; }
        public string diversity { get; set; }
        public int mood { get; set; }
        public int energy { get; set; }
        public string mood_energy { get; set; }
    }
}
