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

namespace Cassette {
    public abstract class PlayButton : CustomButton {

        // Не реальное воспроизведение, а считает ли плеер данный трек текущим
        public bool is_current_playing { get; private set; default = false; }

        // Фактическое воспроизведение трека
        protected bool is_playing { get; set; default = false; }

        // Отображать ли текст с воспроизведении
        public bool with_label { get; construct; default = false; }

        construct {
            notify["is-playing"].connect (on_is_playing_notify);
            on_is_playing_notify ();
        }

        void on_is_playing_notify () {
            if (is_playing) {
                tooltip_text = _("Pause");
                icon_name = "media-playback-pause-symbolic";
                if (with_label) {
                    label = _("Pause");
                }

            } else {
                tooltip_text = _("Play");
                icon_name = "media-playback-start-symbolic";
                if (with_label) {
                    label = _("Play");
                }
            }
        }

        public void set_playing () {
            is_playing = true;
            is_current_playing = true;
        }

        public void set_paused () {
            is_playing = false;
            is_current_playing = true;
        }

        public void set_stopped () {
            is_playing = false;
            is_current_playing = false;
        }
    }
}
