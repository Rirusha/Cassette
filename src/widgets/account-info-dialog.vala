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
    [GtkTemplate (ui = "/space/rirusha/Cassette/ui/account-info-dialog.ui")]
    public class AccountInfoDialog : Adw.Dialog {
        [GtkChild]
        unowned Adw.Avatar avatar;
        //  [GtkChild]
        //  unowned Gtk.Label login_label;
        //  [GtkChild]
        //  unowned Gtk.Label plus_label;
        [GtkChild]
        unowned Gtk.Label public_name_label;

        public YaMAPI.Account.About account_info { get; construct; }

        public AccountInfoDialog (YaMAPI.Account.About account_info) {
            Object (account_info: account_info);
        }

        construct {
            load_avatar.begin ();

            public_name_label.label = account_info.public_name;

            if (Cassette.application.is_devel) {
                add_css_class ("devel");
            }
        }

        async void load_avatar () {
            avatar.text = account_info.public_name;
            avatar.size = 200;
            var pixbuf = yield Cachier.get_image (account_info, 200);
            if (pixbuf != null) {
                avatar.custom_image = Gdk.Texture.for_pixbuf (pixbuf);
            }
        }
    }
}
