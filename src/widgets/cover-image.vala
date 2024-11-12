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

[GtkTemplate (ui = "/space/rirusha/Cassette/ui/cover-image.ui")]
public sealed class Cassette.CoverImage : Gtk.Frame {

    [GtkChild]
    unowned Gtk.Image real_image;

    public CoverSize cover_size { get; set; default = CoverSize.BIG; }

    public HasCover yam_object { get; private set; }

    /**
     * Easy way to set both width and height of the cover widget.
     */
    public int image_widget_size {
        get {
            return real_image.width_request == real_image.height_request ? real_image.height_request : -1;
        }
        set {
            real_image.width_request = value;
            real_image.height_request = value;
        }
    }

    construct {
        notify["cover-size"].connect (() => {
            switch (cover_size) {
                case CoverSize.SMALL:
                    real_image.icon_size = Gtk.IconSize.NORMAL;
                    add_css_class ("small-border-radius");
                    break;

                case CoverSize.BIG:
                    real_image.icon_size = Gtk.IconSize.LARGE;
                    remove_css_class ("small-border-radius");
                    break;

                default:
                    assert_not_reached ();
            }
        });
    }

    public void init_content (HasCover yam_object) {
        real_image.icon_name = "audio-x-generic-symbolic";
        this.yam_object = yam_object;
        add_css_class ("card");
    }

    public void clear () {
        real_image.icon_name = null;
        yam_object = null;
        remove_css_class ("card");
    }

    public async void load_image () {
        assert (yam_object != null);

        Gdk.Pixbuf? pixbuf_buffer = null;

        pixbuf_buffer = yield Cachier.get_image (yam_object, (int) cover_size);

        if (pixbuf_buffer != null) {
            real_image.set_from_paintable (Gdk.Texture.for_pixbuf (pixbuf_buffer));
        }
    }
}
