/*
 * Copyright (C) 2026 Vladimir Romanov <rirusha@altlinux.org>
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see
 * <https://www.gnu.org/licenses/gpl-3.0-standalone.html>.
 * 
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

internal sealed class Cassette.Badge : Adw.Bin {

    public bool needs_attention { get; set; }

    public uint badge_number { get; set; }

    construct {
        visible = false;
        valign = CENTER;
        css_classes = { "indicator", "dot" };

        notify["needs-attention"].connect (update_badge);
        notify["badge-number"].connect (update_badge);
        update_badge ();
    }

    public void update_badge () {
        Gtk.Label? label = null;

        if (child != null) {
            label = (Gtk.Label) child;
        }

        if (!needs_attention && badge_number == 0) {
            visible = false;
            return;
        }

        if (visible && label == null && needs_attention && badge_number == 0) {
            return;
        }

        if (badge_number > 0) {
            if (label == null) {
                label = new Gtk.Label (null) {
                    css_classes = { "numeric" }
                };

                child = label;
            }

            if (badge_number > 999) {
                label.label = "999+";
            } else {
                label.label = badge_number.to_string ();
            }

            remove_css_class ("dot");

        } else if (label != null) {
            child = null;
            label = null;

            add_css_class ("dot");
        }

        if (needs_attention) {
            add_css_class ("needs-attention");
        } else {
            remove_css_class ("needs-attention");
        }

        visible = true;
    }
}
