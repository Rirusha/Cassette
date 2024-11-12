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

[GtkTemplate (ui = "/space/rirusha/Cassette/ui/track-info-panel.ui")]
public class Cassette.TrackInfoPanel : Adw.Bin, Gtk.Orientable {

    [GtkChild]
    unowned CoverImage cover_image;
    [GtkChild]
    unowned Gtk.Label position_label;
    [GtkChild]
    unowned PlayMarkTrack play_mark_track;
    [GtkChild]
    unowned Gtk.Box main_box;
    [GtkChild]
    unowned Gtk.Stack cover_stack;
    [GtkChild]
    unowned Gtk.Box title_box;
    [GtkChild]
    unowned Adw.Bin cover_bin;
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

    YaMAPI.Track? _track_info = null;
    public YaMAPI.Track? track_info {
        get {
            return _track_info;
        }
        set {
            _track_info = value;

            if (value == null) {
                track_name_label.label = "";
                track_version_label.label = "";
                track_authors_label.label = "";

                info_marks.is_exp = false;
                info_marks.is_child = false;
                info_marks.replaced_by = null;

                cover_image.clear ();

            } else {
                track_name_label.label = value.title == null ? "" : value.title;
                track_version_label.label = value.title == null ? "" : value.version;
                track_authors_label.label = value.get_artists_names ();

                info_marks.is_exp = track_info.is_explicit;
                info_marks.is_child = track_info.is_suitable_for_children;
                info_marks.replaced_by = track_info.substituted;

                if (load_cover) {
                    cover_image.init_content (track_info);
                    cover_image.load_image.begin ();
                }

                play_mark_track.init_content (value.id);
            }

            update_labels_visibility ();
        }
    }

    public int image_size_allocate {
        get {
            return cover_bin.width_request;
        }
        construct set {
            cover_bin.width_request = value;
            cover_bin.height_request = value;
        }
    }

    public int image_actual_size {
        get {
            return cover_image.image_widget_size;
        }
        set {
            if (value == -1) {
                if (orientation == Gtk.Orientation.HORIZONTAL) {
                    cover_image.image_widget_size = 60;

                } else {
                    cover_image.image_widget_size = 200;
                }

            } else {
                cover_image.image_widget_size = value;
            }
        }
    }

    public int position { get; set; }

    public bool load_cover { get; construct; default = true; }

    Gtk.Orientation _orientation = Gtk.Orientation.HORIZONTAL;
    public Gtk.Orientation orientation {
        get {
            return _orientation;
        }
        set {
            _orientation = value;

            title_and_marks_box.start_widget = null;
            title_and_marks_box.center_widget = null;
            title_and_marks_box.end_widget = null;

            main_box.orientation = _orientation;

            switch (_orientation) {
                case Gtk.Orientation.HORIZONTAL:
                    track_name_label.add_css_class ("heading");
                    track_name_label.remove_css_class ("title-3");
                    track_version_label.add_css_class ("caption");

                    track_name_label.add_css_class ("unbold");
                    track_version_label.add_css_class ("unbold");
                    track_authors_label.add_css_class ("unbold");

                    track_name_label.halign = Gtk.Align.START;
                    track_version_label.halign = Gtk.Align.START;
                    track_authors_label.halign = Gtk.Align.START;

                    track_name_label.wrap = false;
                    track_version_label.wrap = false;
                    track_authors_label.wrap = false;

                    track_name_label.ellipsize = Pango.EllipsizeMode.END;
                    track_version_label.ellipsize = Pango.EllipsizeMode.END;
                    track_authors_label.ellipsize = Pango.EllipsizeMode.END;

                    track_name_label.justify = Gtk.Justification.LEFT;
                    track_version_label.justify = Gtk.Justification.LEFT;
                    track_authors_label.justify = Gtk.Justification.LEFT;

                    title_and_marks_box.halign = Gtk.Align.START;

                    title_and_marks_box.start_widget = title_box;
                    title_and_marks_box.center_widget = info_marks;

                    cover_image.cover_size = CoverSize.SMALL;
                    cover_image.image_widget_size = image_actual_size == -1 ? 60 : image_actual_size;
                    break;

                case Gtk.Orientation.VERTICAL:
                    track_name_label.remove_css_class ("heading");
                    track_name_label.add_css_class ("title-3");
                    track_version_label.remove_css_class ("caption");

                    track_name_label.remove_css_class ("unbold");
                    track_version_label.remove_css_class ("unbold");
                    track_authors_label.remove_css_class ("unbold");

                    track_name_label.halign = Gtk.Align.CENTER;
                    track_version_label.halign = Gtk.Align.CENTER;
                    track_authors_label.halign = Gtk.Align.CENTER;

                    track_name_label.wrap = true;
                    track_version_label.wrap = true;
                    track_authors_label.wrap = true;

                    track_name_label.ellipsize = Pango.EllipsizeMode.NONE;
                    track_version_label.ellipsize = Pango.EllipsizeMode.NONE;
                    track_authors_label.ellipsize = Pango.EllipsizeMode.NONE;

                    track_name_label.justify = Gtk.Justification.CENTER;
                    track_version_label.justify = Gtk.Justification.CENTER;
                    track_authors_label.justify = Gtk.Justification.CENTER;

                    title_and_marks_box.halign = Gtk.Align.CENTER;

                    title_and_marks_box.center_widget = title_box;
                    title_and_marks_box.end_widget = info_marks;

                    cover_image.cover_size = CoverSize.BIG;
                    cover_image.image_widget_size = image_actual_size == -1 ? 200 : image_actual_size;
                    break;
            }
        }
    }

    public TrackInfoPanel (
        Gtk.Orientation orientation
    ) {
        Object (
            orientation: orientation
        );
    }

    construct {
        notify["position"].connect (() => {
            position_label.label = position.to_string ();
        });
    }

    void update_labels_visibility () {
        track_version_label.visible = track_version_label.label != "";
        track_authors_label.visible = track_authors_label.label != "";
    }

    public PlayMarkTrack get_play_mark_track () {
        return play_mark_track;
    }

    public void show_play_button () {
        cover_stack.visible_child_name = "play-mark";
    }

    public void show_cover () {
        cover_stack.visible_child_name = "cover";
    }

    public void show_position () {
        cover_stack.visible_child_name = "position";
    }
}
