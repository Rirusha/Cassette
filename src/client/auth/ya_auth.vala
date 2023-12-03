/* ya_auth.vala
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

using Cassette;

namespace CassetteClient.YaMAuth {

    public enum Status {
        OK,
        ERROR
    }

    public class YaAuth : Object{

        public SoupWrapper soup_wrapper { get; construct; }
    
        private string csrf_token;
        private string track_id;

        public bool is_init_complete { get; set; default = false; }

        public YaAuth (SoupWrapper soup_wrapper) {
            Object (soup_wrapper: soup_wrapper);
        }

        public void init () throws ClientError, BadStatusCodeError {
            soup_wrapper.clear_cookies ();
            update_csrf_token ();

            is_init_complete = true;
        }

        private void update_csrf_token () throws ClientError, BadStatusCodeError {
            Bytes bytes = soup_wrapper.get_sync ("https://passport.yandex.ru/am?app_platform=android");

            Regex regex = null;
            try {
                regex = new Regex ("csrf_token\" value=\"([^\"]+)\"", RegexCompileFlags.OPTIMIZE, RegexMatchFlags.NOTEMPTY);
            } catch (Error e) {
                throw new ClientError.AUTH_ERROR (_("Failed while getting csrf token"));
            }

            MatchInfo match_info;
            if (regex.match ((string) bytes.get_data (), 0, out match_info)) {
                csrf_token = match_info.fetch (1);
            }
        }

        public LoginInfo login_username (string username) throws ClientError, BadStatusCodeError {
            var datalist = Datalist<string> ();
            datalist.set_data ("csrf_token", csrf_token);
            datalist.set_data ("login", username);

            PostContent post_content = {"application/x-www-form-urlencoded"};
            post_content.set_datalist (datalist);

            Bytes bytes = soup_wrapper.post_sync ("https://passport.yandex.ru/registration-validations/auth/multi_step/start", null, post_content);
            
            var jsoner = Jsoner.from_bytes (bytes, null, Case.SNAKE_CASE);
            var login_info = (LoginInfo) jsoner.deserialize_object (typeof (LoginInfo));

            track_id = login_info.track_id;

            return login_info;
        }

        public CompleteInfo login_password (string password) throws ClientError, BadStatusCodeError {
            var datalist = Datalist<string> ();
            datalist.set_data ("csrf_token", csrf_token);
            datalist.set_data ("track_id", track_id);
            datalist.set_data ("password", password);
            datalist.set_data ("retpath", "https://oauth.yandex.ru/authorize?response_type=token&client_id=23cabbbdc6cd418abb4b39c32c41195d&redirect_uri=https%3A%2F%2Fmusic.yandex.ru%2F&force_confirm=False&language=ru");

            PostContent post_content = {"application/x-www-form-urlencoded"};
            post_content.set_datalist (datalist);

            Bytes bytes = soup_wrapper.post_sync ("https://passport.yandex.ru/registration-validations/auth/multi_step/commit_password", null, post_content);
            var jsoner = Jsoner.from_bytes (bytes, null, Case.SNAKE_CASE);
            var complete_info = (CompleteInfo) jsoner.deserialize_object (typeof (CompleteInfo));

            return complete_info;
        }
    
        public string get_qr_url () throws ClientError, BadStatusCodeError {
            var datalist = Datalist<string> ();
            datalist.set_data ("csrf_token", csrf_token);
            datalist.set_data ("retpath", "https://passport.yandex.ru/profile");
            datalist.set_data ("with_code", "1");

            PostContent post_content = {"application/x-www-form-urlencoded"};
            post_content.set_datalist (datalist);

            Bytes bytes = soup_wrapper.post_sync ("https://passport.yandex.ru/registration-validations/auth/password/submit", null, post_content);
            var jsoner = Jsoner.from_bytes (bytes, null, Case.SNAKE_CASE);
            var login_info = (LoginInfo) jsoner.deserialize_object (typeof (LoginInfo));

            csrf_token = login_info.csrf_token;
            track_id = login_info.track_id;

            if (login_info.status != "ok") {
                throw new ClientError.AUTH_ERROR (_("Error while getting qr-code uri"));
            }

            return @"https://passport.yandex.ru/auth/magic/code/?track_id=$(track_id)";
        }

        public bool login_qr () throws ClientError, BadStatusCodeError {
            var datalist = Datalist<string> ();
            datalist.set_data ("csrf_token", csrf_token);
            datalist.set_data ("track_id", track_id);

            PostContent post_content = {"application/x-www-form-urlencoded"};
            post_content.set_datalist (datalist);

            Bytes bytes = soup_wrapper.post_sync ("https://passport.yandex.ru/auth/new/magic/status", null, post_content);
            var jsoner = Jsoner.from_bytes (bytes, null, Case.SNAKE_CASE);
            var complete_info = (CompleteInfo) jsoner.deserialize_object (typeof (CompleteInfo));

            if (complete_info.status == "ok") {
                return true;
            } else {
                return false;
            }
        }

        public Bytes get_content_of (string uri) throws ClientError, BadStatusCodeError {
            return soup_wrapper.get_sync (uri);
        }
    }
}