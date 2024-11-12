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


namespace Cassette {
    [GtkTemplate (ui = "/space/rirusha/Cassette/ui/save-stack.ui")]
    public class SaveStack : Adw.Bin, Initable {

        [GtkChild]
        unowned Gtk.Stack save_stack;
        [GtkChild]
        unowned Gtk.Spinner save_spin;
        [GtkChild]
        unowned Gtk.Image temp_mark_image;
        [GtkChild]
        unowned Gtk.Image perm_mark_image;

        public bool show_anyway { get; set; default = false; }

        protected string content_id { get; set; }
        public Cachier.ContentType content_type { get; construct; }

        // Нужно для резервирования места под виджет
        public bool hide_when_none { get; construct; default = false; }

        ulong con_id = -1;

        public SaveStack () {
            Object ();
        }

        string get_content_name () {
            switch (content_type) {
                case Cachier.ContentType.ALBUM:
                    return _("Album");
                case Cachier.ContentType.IMAGE:
                    return _("Image");
                case Cachier.ContentType.PLAYLIST:
                    return _("Playlist");
                case Cachier.ContentType.TRACK:
                    return _("Track");
                default:
                    assert_not_reached ();
            }
        }

        construct {
            Cassette.settings.changed.connect ((key) => {
                if (content_id == null) {
                    return;
                }

                if (key == "show-save-stack" || key == "show-temp-save-mark") {
                    cache_state_changed (cachier.controller.get_content_cache_state (content_type, content_id));
                }
            });

            save_spin.tooltip_text = _("%s saving…").printf (get_content_name ());
            temp_mark_image.tooltip_text = _("%s cached").printf (get_content_name ());
            perm_mark_image.tooltip_text = _("%s saved").printf (get_content_name ());

            if (hide_when_none == true) {
                visible = false;

                save_stack.notify["visible-child-name"].connect (() => {
                    if (save_stack.visible_child_name == "none") {
                        visible = false;
                    } else {
                        visible = true;
                    }
                });
            }
        }

        public void clear () {
            cache_state_changed (Cachier.CacheingState.NONE);
        }

        public void init_content (string content_id) {
            this.content_id = content_id;

            if (con_id != -1) {
                cachier.controller.content_cache_state_changed.disconnect (on_content_cache_state_changed);
                con_id = -1;
            }

            con_id = cachier.controller.content_cache_state_changed.connect (on_content_cache_state_changed);

            cache_state_changed (cachier.controller.get_content_cache_state (content_type, content_id));
        }

        void on_content_cache_state_changed (Cachier.ContentType content_type, string content_id, Cachier.CacheingState state) {
            if (this.content_id == content_id && this.content_type == content_type) {
                cache_state_changed (state);
            }
        }

        void cache_state_changed (owned Cachier.CacheingState state) {
            if (!Cassette.settings.get_boolean ("show-save-stack")) {
                state = Cachier.CacheingState.NONE;
            }

            switch (state) {
                case Cachier.CacheingState.NONE:
                    save_stack.visible_child_name = "none";
                    save_spin.stop ();
                    break;
                case Cachier.CacheingState.LOADING:
                    save_stack.visible_child_name = "loading";
                    save_spin.start ();
                    break;
                case Cachier.CacheingState.TEMP:
                    if (Cassette.settings.get_boolean ("show-temp-save-mark") || show_anyway) {
                        save_stack.visible_child_name = "temp";
                    } else {
                        save_stack.visible_child_name = "none";
                    }
                    save_spin.stop ();
                    break;
                case Cachier.CacheingState.PERM:
                    save_stack.visible_child_name = "perm";
                    save_spin.stop ();
                    break;
            }
        }
    }
}
