/* cover_image.vala
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
using Gee;


namespace Cassette {
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/cover_image.ui")]
    public class CoverImage : Adw.Bin {
        [GtkChild]
        unowned Gtk.Frame cover_frame;
        [GtkChild]
        unowned Gtk.Image real_image;

        HasCover yam_object;
        int cover_size;

        public CoverImage () {
            Object ();
        }

        public void init_content (HasCover yam_object, ArtSize size) {
            this.yam_object = yam_object;

            int widget_size;
            if (size == ArtSize.BIG_ART) {
                cover_frame.add_css_class ("big-art");
                real_image.icon_size = Gtk.IconSize.LARGE;
                widget_size = 200;

            } else if (size == ArtSize.TRACK || size == ArtSize.BIG_SMALL) {
                cover_frame.add_css_class ("small-art");
                widget_size = 60;

            } else {
                assert_not_reached ();
            }

            width_request = widget_size;
            real_image.width_request = widget_size;
            height_request = widget_size;
            real_image.height_request = widget_size;
            cover_size = (int) size;
        }

        public void clear () {
            real_image.icon_name = "adwaita-audio-x-generic-symbolic";
        }

        public async void load_image () {
            Gdk.Pixbuf? pixbuf_buffer = null;

            pixbuf_buffer = yield Cachier.get_image (yam_object, cover_size);

            if (pixbuf_buffer != null) {
                real_image.set_from_paintable (Gdk.Texture.for_pixbuf (pixbuf_buffer));
            } else {
                cover_frame.add_css_class ("gray-background");
            }
        }
    }
}
