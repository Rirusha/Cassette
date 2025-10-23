/* Copyright 2023-2025 Vladimir Romanov
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


using Tape;
using Tape.YaMAPI;
using Gee;

[GtkTemplate (ui = "/space/rirusha/Cassette/ui/cover-image.ui")]
public sealed class Cassette.CoverImage : Gtk.Frame {

    [GtkChild]
    unowned Gtk.Image placeholder_image;
    [GtkChild]
    unowned Gtk.Stack stack;

    public int cover_size { get; set; default = CoverSize.BIG; }

    public HasCover yam_object { get; private set; }

    /**
     * Easy way to set both width and height of the cover widget.
     */
    public int image_widget_size { get; set; }

    construct {
        notify["cover-size"].connect (() => {
            switch (cover_size) {
                case CoverSize.SMALL:
                    placeholder_image.icon_size = Gtk.IconSize.NORMAL;
                    image_widget_size = 60;
                    add_css_class ("small-border-radius");
                    break;

                case CoverSize.BIG:
                    placeholder_image.icon_size = Gtk.IconSize.LARGE;
                    image_widget_size = 200;
                    remove_css_class ("small-border-radius");
                    break;

                default:
                    assert_not_reached ();
            }
        });
    }

    public void init_content (HasCover yam_object) {
        this.yam_object = yam_object;
        add_css_class ("card");
    }

    public void clear () {
        yam_object = null;
        remove_css_class ("card");
    }

    public async void load_image () {
        assert (yam_object != null);

        Gdk.Pixbuf? pixbuf_buffer = null;

        //  pixbuf_buffer = yield Cachier.get_image (yam_object, (int) cover_size);

        if (pixbuf_buffer != null) {
            var real_image = new Gtk.Image ();
            real_image.set_from_paintable (Gdk.Texture.for_pixbuf (pixbuf_buffer));

            bind_property (
                "image-widget-size",
                real_image,
                "width-request",
                GLib.BindingFlags.SYNC_CREATE
            );
            bind_property (
                "image-widget-size",
                real_image,
                "height-request",
                GLib.BindingFlags.SYNC_CREATE
            );
            bind_property (
                "image-widget-size",
                real_image,
                "pixel-size",
                GLib.BindingFlags.SYNC_CREATE
            );

            stack.add_child (real_image);

            stack.visible_child = real_image;
        }
    }
}
