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


[GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/action_card_banner.ui")]
/**
    * A class for convenient work with clickable cards.
    */
public class Cassette.ActionCardBanner : ActionCardCustom, Gtk.Orientable {

    [GtkChild]
    unowned Gtk.Box content_box;
    [GtkChild]
    unowned Gtk.Image content_image;
    [GtkChild]
    unowned Gtk.Label content_label;

    public Gtk.Orientation orientation {
        get {
            return content_box.orientation;
        }
        set {
            content_box.orientation = value;
        }
    }

    public Gtk.IconSize icon_size {
        get {
            return content_image.icon_size;
        }
        set {
            content_image.icon_size = value;
        }
    }

    public string? icon_name {
        owned get {
            return content_image.icon_name;
        }
        set {
            content_image.icon_name = value;
        }
    }

    public string label {
        get {
            return content_label.label;
        }
        set {
            content_label.label = value;
        }
    }

    public ActionCardBanner.with_data (
        string label,
        string? icon_name
    ) {
        Object (
            label: label,
            icon_name: icon_name
        );
    }
}