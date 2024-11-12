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


using Cassette.Client;
using Gee;


namespace Cassette {
    [GtkTemplate (ui = "/space/rirusha/Cassette/ui/lyrics-panel.ui")]
    public class LyricsPanel : Adw.Bin {
        [GtkChild]
        unowned Gtk.Box lines_box;

        public string track_id { get; set; }

        bool is_text = true;

        LyricsLine? _current_line = null;
        LyricsLine? current_line {
            get {
                return _current_line;
            }
            set {
                if (_current_line != null && _current_line.is_big) {
                    _current_line.small ();
                }
                _current_line = value;
                if (_current_line != null && !_current_line.is_big) {
                    _current_line.big ();
                }
            }
        }
        LinkedList<LyricsLine> line_list;

        //  uint? tout = null;

        public LyricsPanel () {
            Object ();
        }

        public void set_sync_lyrics_lines (string[] lines) {
            line_list = new LinkedList<LyricsLine> ();
            LyricsLine lyrics_line;
            lyrics_line = new LyricsLine.sync ("", 0);
            lines_box.append (lyrics_line);
            line_list.add (lyrics_line);

            foreach (string line in lines) {
                string[] data = line.split (" ", 2);
                int64 time_ms = parse_time (data[0]);
                lyrics_line = new LyricsLine.sync (data[1], time_ms);
                lines_box.append (lyrics_line);
                line_list.add (lyrics_line);
            }

            Timeout.add (100, () => {
                if (track_id != player.mode.get_current_track_info ().id || player.state != Player.State.PLAYING) {
                    current_line = null;
                    show_as_text ();

                } else {
                    show_as_sync ();
                    int64 current_ms = player.playback_pos_ms;
                    for (int i = 0; i < line_list.size - 1; i++) {
                        if (line_list[i].time_ms > current_ms) {
                            break;
                        }
                        if (line_list[i + 1].time_ms > current_ms && current_line != line_list[i]) {
                            current_line = line_list[i];
                            if (current_line.is_empty) {
                                current_line.wait (line_list[i + 1].time_ms);
                            }
                            break;
                        }
                    }
                }

                if (get_mapped ()) {
                    return Source.CONTINUE;

                } else {
                    return Source.REMOVE;
                }
            });
        }

        void show_as_text () {
            if (!is_text) {
                is_text = true;
                foreach (var line in line_list) {
                    line.make_text ();
                }
            }
        }

        void show_as_sync () {
            if (is_text) {
                is_text = false;
                foreach (var line in line_list) {
                    line.make_sync ();
                }
            }
        }

        public void set_text_lyrics_lines (string[] lines) {
            string text = string.joinv ("\n", lines);
            lines_box.append (new LyricsLine.text (text));
        }
    }
}
