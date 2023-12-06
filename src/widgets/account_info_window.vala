/* account_info_window.vala
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
using CassetteClient.YaMAuth;


namespace Cassette {
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/account_info_window.ui")]
    public class AccountInfoWindow : Adw.Window {
        [GtkChild]
        unowned Adw.Avatar avatar;
        [GtkChild]
        unowned Gtk.Label login_format_label;
        [GtkChild]
        unowned Gtk.Label phone_format_label;
        [GtkChild]
        unowned Gtk.Label plus_label;
        [GtkChild]
        unowned Gtk.Label add_label;
        [GtkChild]
        unowned Gtk.Box options_box;
        [GtkChild]
        unowned Gtk.Label first_name_format_label;
        [GtkChild]
        unowned Gtk.Label second_name_format_label;
        [GtkChild]
        unowned Gtk.Label display_name_format_label;
        [GtkChild]
        unowned Gtk.Label birthday_format_label;

        public YaMAPI.AccountInfo account_info { get; construct; }

        public AccountInfoWindow (YaMAPI.AccountInfo account_info) {
            Object (account_info: account_info);
        }

        construct {
            load_avatar.begin ();

            if (account_info.account.login != null) {
                login_format_label.label = login_format_label.label.printf (account_info.account.login);
                login_format_label.visible = true;
            }

            if (account_info.account.passport_phones.size != 0) {
                phone_format_label.label = phone_format_label.label.printf (account_info.account.passport_phones[0].phone);
                phone_format_label.visible = true;
            }

            plus_label.visible = account_info.plus.has_plus;

            if (account_info.has_options.size != 0) {
                add_label.visible = true;
                options_box.visible = true;

                foreach (var option in account_info.has_options) {
                    string name;

                    switch (option) {
                        case "bookmate":
                            name = "Bookmate";
                            break;
                        default:
                            assert_not_reached ();
                    }

                    var label = new Gtk.Label (name) { halign = Gtk.Align.START, margin_start = 4 };
                    label.add_css_class ("title-5");
                    options_box.append (label);
                }
            }

            if (account_info.account.first_name != null) {
                first_name_format_label.label = first_name_format_label.label.printf (account_info.account.first_name);
                first_name_format_label.visible = true;
            }

            if (account_info.account.second_name != null) {
                second_name_format_label.label = second_name_format_label.label.printf (account_info.account.second_name);
                second_name_format_label.visible = true;
            }

            if (account_info.account.display_name != null) {
                display_name_format_label.label = display_name_format_label.label.printf (account_info.account.display_name);
                display_name_format_label.visible = true;
            }

            if (account_info.account.birthday != null) {
                birthday_format_label.label = birthday_format_label.label.printf (account_info.account.birthday);
                birthday_format_label.visible = true;
            }

            if (Config.POSTFIX == ".Devel") {
                add_css_class ("devel");
            }
        }

        async void load_avatar () {
            threader.add (() => {
                avatar.text = account_info.account.get_user_name ();
                avatar.size = 200;
                var pixbuf = get_image (account_info, 200);
                if (pixbuf != null) {
                    avatar.custom_image = Gdk.Texture.for_pixbuf (pixbuf);
                }

                Idle.add (load_avatar.callback);
            });

            yield;
        }
    }
}
