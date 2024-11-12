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

using Gee;

namespace Cassette {
    [GtkTemplate (ui = "/space/rirusha/Cassette/ui/lyrics-line.ui")]
    public class LyricsLine : Adw.Bin {
        [GtkChild]
        unowned Gtk.Revealer line_small;
        [GtkChild]
        unowned Gtk.Label line_big_label;
        [GtkChild]
        unowned Gtk.Label line_small_label;

        public bool is_big {
            get {
                return line_big_label.visible;
            }
        }

        public bool is_empty {
            get {
                return line == "";
            }
        }

        public string line { get; construct set; }
        public int64 time_ms { get; construct set; default = -1; }

        int64 next_time;
        uint diff_con = -1;

        Gtk.GestureClick? gesture_click = null;
        Gtk.EventControllerMotion? event_motion = null;

        public LyricsLine.text (string line) {
            Object (line: line);
        }

        public LyricsLine.sync (string? line, int64 time_ms) {
            Object (line: line, time_ms: time_ms);
        }

        construct {
            line_small_label.label = line;
            line_big_label.label = line;

            line_small.bind_property ("visible", line_big_label, "visible", GLib.BindingFlags.INVERT_BOOLEAN);
            line_small.bind_property ("visible", line_small, "reveal-child", BindingFlags.DEFAULT);
        }

        public void big () {
            line_small.visible = false;
        }

        public void small () {
            line_small.visible = true;
        }

        public void make_text () {
            line_small_label.remove_css_class ("dim-label");

            if (gesture_click != null) {
                line_small.remove_controller (gesture_click);
            }
            if (event_motion != null) {
                line_small.remove_controller (event_motion);
            }
        }

        public void make_sync () {
            if (line != "") {
                line_small_label.add_css_class ("dim-label");

                gesture_click = new Gtk.GestureClick ();
                gesture_click.released.connect ((n_press, x, y) => {
                    player.seek (time_ms);
                });
                line_small.add_controller (gesture_click);

                event_motion = new Gtk.EventControllerMotion ();
                event_motion.enter.connect (() => {
                    line_small_label.remove_css_class ("dim-label");
                });
                event_motion.leave.connect (() => {
                    line_small_label.add_css_class ("dim-label");
                });
                line_small.add_controller (event_motion);
            }
        }

        public void wait (int64 next_time_ms) {
            next_time = next_time_ms;

            if (diff_con != -1) {
                Source.remove (diff_con);
            }

            diff_con = Timeout.add (100, () => {
                var diff = (next_time - player.playback_pos_ms) / 1000;

                if (diff > 6 ) {
                    line_big_label.label = "   < . . . >";
                    return Source.CONTINUE;
                } else if (diff < 0) {
                    diff_con = -1;
                    return Source.REMOVE;
                }
                line_big_label.label = "   " + (diff + 1).to_string ();
                return Source.CONTINUE;
            }, Priority.HIGH_IDLE);
        }
    }
}
