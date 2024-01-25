/* track_info_panel.vala
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

using CassetteClient;


namespace Cassette {
[GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/track_info_panel.ui")]
    public class TrackInfoPanel : Adw.Bin {
        [GtkChild]
        unowned Gtk.Box main_box;
        [GtkChild]
        unowned Gtk.Stack cover_stack;
        [GtkChild]
        unowned Gtk.CenterBox title_and_marks_box;
        [GtkChild]
        unowned Gtk.Label track_name_label;
        [GtkChild]
        unowned Gtk.Label track_version_label;
        [GtkChild]
        unowned Gtk.Label track_authors_label;
        [GtkChild]
        unowned InfoMarks info_marks;

        public string track_id {
            owned get {
                if (_track_info == null) {
                    return "";
                } else {
                    return _track_info.id;
                }
            }
        }

        YaMAPI.Track? _track_info = null;
        public YaMAPI.Track? track_info {
            get {
                return _track_info;
            }
            set {
                _track_info = value;

                if (_track_info == null) {
                    track_name_label.label = "";
                    track_version_label.label = "";
                    track_authors_label.label = "";

                    info_marks.is_exp = false;
                    info_marks.is_child = false;
                    info_marks.replaced_by = null;

                    if (has_cover) {
                        cover_image.clear ();
                        cover_image.visible = has_cover_placeholder;
                    }

                } else {
                    track_name_label.label = _track_info.title;
                    track_version_label.label = _track_info.version;
                    track_authors_label.label = _track_info.get_artists_names ();

                    info_marks.is_exp = track_info.is_explicit;
                    info_marks.is_child = track_info.is_suitable_for_children;
                    info_marks.replaced_by = track_info.substituted;

                    if (has_cover) {
                        cover_image.init_content (
                            track_info,
                            orientation == Gtk.Orientation.HORIZONTAL? ArtSize.TRACK : ArtSize.BIG_ART
                        );
                        cover_image.load_image.begin ();
                        cover_image.visible = true;
                    }

                    if (has_play_button) {
                        play_button.init_content (_track_info.id);
                    }
                }
            }
        }

        public PlayButtonTrack play_button {
            get {
                assert (cover_stack.get_child_by_name ("play-button") != null);

                return (PlayButtonTrack) cover_stack.get_child_by_name ("play-button");
            }
        }

        CoverImage cover_image {
            get {
                assert (cover_stack.get_child_by_name ("cover") != null);

                return (CoverImage) cover_stack.get_child_by_name ("cover");
            }
        }

        public bool has_cover { get; construct; default = true; }
        public bool has_play_button { get; construct; default = false; }
        public bool has_cover_placeholder { get; construct; default = true; }

        public Gtk.Orientation orientation { get; construct; }

        public TrackInfoPanel (Gtk.Orientation orientation) {
            Object (orientation: orientation);
        }

        public TrackInfoPanel.without_placeholder (Gtk.Orientation orientation) {
            Object (orientation: orientation, has_cover_placeholder: false);
        }

        construct {
            track_version_label.notify["label"].connect (() => {
                track_version_label.visible = track_version_label.label != "";
            });

            track_authors_label.notify["label"].connect (() => {
                track_authors_label.visible = track_authors_label.label != "";
            });

            if (orientation == Gtk.Orientation.VERTICAL) {
                main_box.orientation = orientation;

                track_name_label.halign = Gtk.Align.CENTER;
                track_version_label.halign = Gtk.Align.CENTER;
                track_authors_label.halign = Gtk.Align.CENTER;

                title_and_marks_box.halign = Gtk.Align.CENTER;

                var w = title_and_marks_box.center_widget;
                title_and_marks_box.center_widget = null;
                title_and_marks_box.end_widget = w;

                w = title_and_marks_box.start_widget;
                title_and_marks_box.start_widget = null;
                title_and_marks_box.center_widget = w;
            }

            if (has_cover) {
                cover_stack.add_named (new CoverImage (), "cover");
            }

            if (has_play_button) {
                cover_stack.add_named (new PlayButtonTrack () { is_flat = true }, "play-button");
            }
        }

        public void show_play_button () {
            assert (cover_stack.get_child_by_name ("play-button") != null);

            cover_stack.visible_child_name = "play-button";
        }

        public void show_cover () {
            assert (cover_stack.get_child_by_name ("cover") != null);

            cover_stack.visible_child_name = "cover";
        }
    }
}
