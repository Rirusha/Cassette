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
    public class CoverImage : Adw.Bin {   

      Gtk.Image real_image { get; default = new Gtk.Image.from_icon_name ("audio-x-generic-symbolic"); }
      HasCover yam_object;

      int cover_size;
        public int size {
            get {
                return cover_size;
            }
            set {
                int widget_size;
                if (value == BIG_ART_SIZE) {
                    widget_size = 200;
                } else if (value == TRACK_ART_SIZE) {
                    widget_size = 50;
                } else if (value == SMALL_BIG_ART_SIZE) {
                    widget_size = 50;
                } else {
                    assert_not_reached ();
                }

                width_request = widget_size;
                height_request = widget_size;
                cover_size = value;
            }
        }

        public CoverImage () {
            Object ();
        }

        construct {
            child = real_image;
        }

        public void init_content (HasCover yam_object, int size) {
            this.yam_object = yam_object;
            this.size = size;
        }

        public void clear () {
            real_image.icon_name = "audio-x-generic-symbolic";
        }

        public async void load_image () {
            Gdk.Pixbuf? pixbuf_buffer = null;

            threader.add_image (() => {
                pixbuf_buffer = get_image (yam_object, cover_size);

                Idle.add (load_image.callback);
            });

            yield;

            if (pixbuf_buffer != null) {
                real_image.set_from_paintable (Gdk.Texture.for_pixbuf (pixbuf_buffer));
            }
        }
    }
}