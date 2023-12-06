/* yaauth_talker.vala
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


using CassetteClient.YaMAuth;


namespace CassetteClient {

    public class YaAuthTalker : AbstractTalker {

        public YaAuth auth { get; private set; }

        public override void init_if_not () throws BadStatusCodeError {
            bool is_need_init = false;

            if (auth == null) {
                is_need_init = true;
            } else {
                is_need_init = !auth.is_init_complete;
            }

            if (is_need_init) {
                init ();
            }
        }

        public void init () throws BadStatusCodeError {
            auth = new YaAuth (create_soup_wrapper (false));

            net_run (() => {
                auth.init ();
            }, false);
        }

        public LoginInfo? login_username (string username) throws BadStatusCodeError {
            LoginInfo? login_info = null;

            net_run (() => {
                login_info = auth.login_username (username);
            });

            return login_info;
        }

        public CompleteInfo login_password (string password) throws BadStatusCodeError {
            CompleteInfo? complete_info = null;

            net_run (() => {
                complete_info = auth.login_password (password);
            });

            return complete_info;
        }

        public Gdk.Texture? get_qr_code () throws BadStatusCodeError {
            Gdk.Texture? qr_code = null;
            string? qr_code_url = null;

            net_run (() => {
                qr_code_url = auth.get_qr_url ();

                try {
                    qr_code = Gdk.Texture.from_bytes (auth.get_content_of (qr_code_url));
                } catch (Error e) { }
            });

            return qr_code;
        }

        public bool login_qr () throws BadStatusCodeError {
            bool login_qr_is_success = false;

            net_run (() => {
                login_qr_is_success = auth.login_qr ();
            });

            return login_qr_is_success;
        }
    }
}
