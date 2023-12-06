/* play_button.vala
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

namespace Cassette {
    public abstract class PlayButton : CustomButton {

        public string label { get; construct; }

        Adw.ButtonContent button_content = new Adw.ButtonContent ();

        public bool is_playing { get; private set; default = false; }

        construct {
            child = real_button;
            tooltip_text = _("Play/Pause");

            button_content.icon_name = "media-playback-start-symbolic";

            if (label != null) {
                button_content.label = label;
            }

            real_button.child = button_content;
        }

        public void set_playing () {
            button_content.icon_name = "media-playback-pause-symbolic";
            is_playing = true;
        }

        public void set_paused () {
            button_content.icon_name = "media-playback-start-symbolic";
            is_playing = true;
        }

        public void set_stopped () {
            set_paused ();
            is_playing = false;
        }
    }
}
