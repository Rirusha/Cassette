/* auth_window.vala
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
    [GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/auth_window.ui")]
    public class AuthWindow : Adw.Window {
        [GtkChild]
        unowned Adw.WindowTitle header_title;
        [GtkChild]
        unowned Adw.ToastOverlay toast_overlay;
        [GtkChild]
        unowned Gtk.Stack main_stack;
        [GtkChild]
        unowned Gtk.Entry username_entry;
        [GtkChild]
        unowned PhoneEntry phone_entry;
        [GtkChild]
        unowned Gtk.Spinner spinner_loading;
        [GtkChild]
        unowned Gtk.Label password_label;
        [GtkChild]
        unowned Gtk.PasswordEntry password_entry;
        [GtkChild]
        unowned Gtk.Image image_qr;   
        [GtkChild]
        unowned Gtk.Button button_local_mode;
        [GtkChild]
        unowned Gtk.Button qr_password_button;

        YaAuthTalker auth = new YaAuthTalker ();

        public signal void bad_close ();
        public signal void choosed_local ();
        public signal void complete ();

        Adw.MessageDialog warning_dialog;

        public AuthWindow (Adw.ApplicationWindow parent) {
            Object ();

            transient_for = parent;
            modal = true;
        }

        construct {
            var action_group = new SimpleActionGroup ();

            var bad_close_action = new SimpleAction ("bad-close", null);
            bad_close_action.activate.connect (() => {
                bad_close ();
            });
            action_group.add_action (bad_close_action);

            var login_action = new SimpleAction ("login", null);
            login_action.activate.connect (login_username);
            action_group.add_action (login_action);

            var login_phone_action = new SimpleAction ("login_phone", null);
            login_phone_action.activate.connect (login_phone);
            action_group.add_action (login_phone_action);

            var password_action = new SimpleAction ("password", null);
            password_action.activate.connect (enter_password);
            action_group.add_action (password_action);

            var show_qr_action = new SimpleAction ("show-qr", null);
            show_qr_action.activate.connect (show_qr);
            action_group.add_action (show_qr_action);

            var local_action = new SimpleAction ("local", null);
            local_action.activate.connect (local);
            action_group.add_action (local_action);

            insert_action_group ("auth", action_group);

            main_stack.notify["visible-child"].connect (() => {
                if (main_stack.visible_child_name == "loading") {
                    spinner_loading.start ();
                } else {
                    spinner_loading.stop ();
                }

                header_title.title = main_stack.get_page (main_stack.visible_child).title;
            });

            block_widget (button_local_mode, BlockReason.NOT_IMPLEMENTED);
            block_widget (phone_entry, BlockReason.NOT_IMPLEMENTED);

            main_stack.notify["visible-child"].connect (() => {
                if (main_stack.visible_child_name == "loading") {
                    spinner_loading.start ();
                } else {
                    spinner_loading.stop ();
                }

                header_title.title = main_stack.get_page (main_stack.visible_child).title;
            });

            username_entry.activate.connect (() => {
                activate_action ("auth.login", null);
            });
            phone_entry.activate.connect (() => {
                activate_action ("auth.login_phone", null);
            });
            password_entry.activate.connect (() => {
                activate_action ("auth.password", null);
            });

            warning_dialog = new Adw.MessageDialog (
                this,
                _("Authorization warning"),
                _("Frequent authorization initialization attempts may lead to Yandex perceiving this as ddos, so please check the data when entering and do not log in too often in a short time. And DON'T USE QR-CODE IF YOU HAVE NOT KEY APP")
            );

            // Translators: "Ok" from message dialog
            warning_dialog.add_response ("ok", _("Ok"));

            warning_dialog.default_response = "ok";
            warning_dialog.close_response = "ok";

            show.connect (warning_dialog.present);

            if (Config.POSTFIX == ".Devel") {
                add_css_class ("devel");
            }
        }

        public void show_message (string message) {
            var toast = new Adw.Toast (message);
            toast_overlay.add_toast (toast);
        }

        async void login_username () {
            string username;
            if (username_entry.text != "") {
                username = username_entry.text;
            } else if (phone_entry.text != "") {
                username = phone_entry.text;
            } else {
                show_message (_("Username/phone can't be empty"));
                return;
            }

            main_stack.visible_child_name = "loading";

            LoginInfo login_info = null;

            threader.add (() => {
                try {
                    login_info = auth.login_username (username);
                } catch (BadStatusCodeError e) {
                    if (e is BadStatusCodeError.UNAUTHORIZE_ERROR) {
                        show_message (_("Yandex send captcha. There nothing we can do. Try later"));
                    }
                }

                Idle.add (login_username.callback);
            });

            yield;

            if (login_info != null) {
                if (login_info.can_register) {
                    main_stack.visible_child_name = "main";
                    show_message (_("User not registered"));
                    return;
                }

                if ("otp" in login_info.auth_methods) {
                    password_label.label = _("Enter code from key app");
                    qr_password_button.visible = true;
                    main_stack.visible_child_name = "password";
                } else if ("password" in login_info.auth_methods) {
                    password_label.label = _("Enter password");
                    main_stack.visible_child_name = "password";
                    qr_password_button.visible = false;
                } else {
                    // Translators: %s here is file path
                    show_message (_("Can't login, create an issue with the attached file %s to github page").printf (storager.log_file_path));
                    Logger.info (_("Auth methods: %s").printf (string.joinv (", ", login_info.auth_methods.to_array ())));
                }
            } else {
                main_stack.visible_child_name = "main";
                show_message (_("Username incorrect"));
            }
        }

        async void login_phone () {
            show_message (_("Not implemented yet"));
        }

        async void enter_password () {
            string password;

            if (password_entry.text != "") {
                password = password_entry.text;
            } else {
                show_message (_("Password/code can't be empty"));
                return;
            }

            main_stack.visible_child_name = "loading";

            CompleteInfo complete_info = null;

            threader.add (() => {
                try {
                    complete_info = auth.login_password (password);
                } catch (BadStatusCodeError e) {  }

                Idle.add (enter_password.callback);
            });

            yield;

            if (complete_info != null) {
                if (complete_info.status == "ok") {
                    complete ();
                    close ();
                }
            } else {
                main_stack.visible_child_name = "password";
                show_message (_("Password/code incorrect"));
            }
        }

        async void show_qr () {
            main_stack.visible_child_name = "loading";

            Gdk.Texture? qr_code = null;

            threader.add (() => {
                try {
                    qr_code = auth.get_qr_code ();

                } catch (BadStatusCodeError e) {
                    if (e is BadStatusCodeError.UNAUTHORIZE_ERROR) {
                        show_message (_("Yandex send captcha. There nothing we can do. Try later"));
                    }
                }

                Thread.usleep (1000000);
                Idle.add (show_qr.callback);
            });

            yield;

            if (qr_code != null) {
                image_qr.set_from_paintable (qr_code);
                main_stack.visible_child_name = "qr";

                threader.add (() => {
                    while (true) {
                        Thread.usleep (1000000);

                        try {
                            if (auth.login_qr ()) {
                                show_qr.callback ();
                            }

                        } catch (BadStatusCodeError e) {
                            show_message (_("Error while checking qr"));
                            Logger.info (_("Error while checking qr. Message: %s").printf (e.message));
                        }
                    }
                });

                yield;

                complete ();
                close ();

            } else {
                main_stack.visible_child_name = "main";
                show_message (_("Error while getting qr-code. Try later"));
            }
        }

        void local () {
            assert_not_reached ();

            //  choosed_local ();
            //  close ();
        }
    }
}
