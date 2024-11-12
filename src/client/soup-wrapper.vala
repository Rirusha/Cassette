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

using Soup;

namespace Cassette.Client {

    public errordomain BadStatusCodeError {
        BAD_REQUEST = 400,
        NOT_FOUND = 404,
        UNAUTHORIZE_ERROR = 403,
        UNKNOWN = 0
    }

    public struct Header {
        string name;
        string value;
    }

    protected class Headers {
        Header[] headers_arr = new Header[0];

        public Headers () { }

        public void add (Header header) {
            headers_arr.resize (headers_arr.length + 1);
            headers_arr[headers_arr.length - 1] = header;
        }

        public void set_headers (Header[] headers_arr) {
            this.headers_arr = headers_arr;
        }

        public Header[] get_headers () {
            return headers_arr;
        }
    }

    public enum PostContentType {
        X_WWW_FORM_URLENCODED,
        JSON
    }

    public struct PostContent {
        PostContentType content_type;
        string content;

        public string get_content_type_string () {
            switch (content_type) {
                case X_WWW_FORM_URLENCODED:
                    return "application/x-www-form-urlencoded";
                case JSON:
                    return "application/json";
                default:
                    assert_not_reached ();
            }
        }

        public Bytes get_bytes () {
            return new Bytes (content.data);
        }

        public void set_datalist (Datalist<string> datalist) {
            switch (content_type) {
                case X_WWW_FORM_URLENCODED:
                    content = Soup.Form.encode_datalist (datalist);
                    break;
                case JSON:
                    content = Jsoner.serialize_datalist (datalist);
                    break;
                default:
                    assert_not_reached ();
            }
        }
    }

    public class SoupWrapper : Object {

        Gee.HashMap<string, Headers> presets_table = new Gee.HashMap<string, Headers> ();

        Soup.Session session = new Soup.Session () {
            timeout = TIMEOUT
        };
        public string? user_agent {
            construct {
                if (value != null) {
                    session.user_agent = value;
                }
            }
        }

        public File? cookies_file {
            construct set {
                if (value == null) {
                    return;
                }

                reload_cookies (value);
            }
        }

        public SoupWrapper (string? user_agent, File? cookies_file) {
            Object (user_agent: user_agent, cookies_file: cookies_file);
        }

        construct {
            if (Logger.log_level == LogLevel.DEVEL) {
                var logger = new Soup.Logger (Soup.LoggerLogLevel.BODY);
                logger.set_printer ((logger, level, direction, data) => {
                    switch (direction) {
                        case '<':
                            Logger.net_in (level, data);
                            break;
                        case '>':
                            Logger.net_out (level, data);
                            break;
                        default:
                            Logger.time ();
                            break;
                    }
                });
                session.add_feature (logger);
            }
        }

        public void reload_cookies (File cookies_file) {
            if (session.has_feature (typeof (Soup.CookieJarDB))) {
                session.remove_feature_by_type (typeof (Soup.CookieJarDB));
            }

            var cookie_jar = new Soup.CookieJarDB (cookies_file.peek_path (), true);
            session.add_feature (cookie_jar);

            Logger.debug ("Cookies was reloaded. New cookiess file %s".printf (
                cookies_file.peek_path ()
            ));
        }

        public void add_headers_preset (string preset_name, Header[] headers_arr) {
            var headers = new Headers ();
            headers.set_headers (headers_arr);
            presets_table.set (preset_name, headers);
        }

        void append_headers_with_preset_to (Message msg, string preset_name) {
            Headers? headers = presets_table.get (preset_name);
            if (headers != null) {
                append_headers_to (msg, headers.get_headers ());
            }
        }

        void append_headers_to (Message msg, Header[] headers_arr) {
            foreach (Header header in headers_arr) {
                msg.request_headers.append (header.name, header.value);
            }
        }

        void add_params_to_uri (string[,]? parameters, ref string uri) {
            string[] parameters_pairs = new string[parameters.length[0]];
            for (int i = 0; i < parameters.length[0]; i++) {
                parameters_pairs[i] = parameters[i,0] + "=" + Uri.escape_string (parameters[i,1]);
            }
            uri += "?" + string.joinv ("&", parameters_pairs);
        }

        Message message_get (
            owned string uri,
            string[]? header_preset_names = null,
            string[,]? parameters = null,
            Header[]? headers = null
        ) {
            if (parameters != null) {
                add_params_to_uri (parameters, ref uri);
            }

            var msg = new Soup.Message ("GET", uri);

            if (header_preset_names != null) {
                foreach (string preset_name in header_preset_names) {
                    append_headers_with_preset_to (msg, preset_name);
                }
            }
            if (headers != null) {
                append_headers_to (msg, headers);
            }

            return msg;
        }

        Message message_post (
            owned string uri,
            string[]? header_preset_names = null,
            PostContent? post_content = null,
            string[,]? parameters = null,
            Header[]? headers = null
        ) {
            if (parameters != null) {
                add_params_to_uri (parameters, ref uri);
            }

            var msg = new Soup.Message ("POST", uri);

            if (post_content != null) {
                msg.set_request_body_from_bytes (
                    post_content.get_content_type_string (),
                    post_content.get_bytes ()
                );
            }

            if (header_preset_names != null) {
                foreach (string preset_name in header_preset_names) {
                    append_headers_with_preset_to (msg, preset_name);
                }
            }
            if (headers != null) {
                append_headers_to (msg, headers);
            }

            return msg;
        }

        void check_status_code (Message msg, Bytes bytes) throws ClientError, BadStatusCodeError {
            if (msg.status_code == Soup.Status.OK) {
                return;
            }

            YaMAPI.ApiError error = new YaMAPI.ApiError ();

            try {
                var jsoner = Jsoner.from_bytes (bytes, {"error"}, Case.CAMEL);
                if (jsoner.root.get_node_type () == Json.NodeType.OBJECT) {
                    error = (YaMAPI.ApiError) jsoner.deserialize_object (typeof (YaMAPI.ApiError));
                } else {
                    jsoner = Jsoner.from_bytes (bytes, null, Case.SNAKE);
                    error = (YaMAPI.ApiError) jsoner.deserialize_object (typeof (YaMAPI.ApiError));
                }
            } catch (ClientError e) { }

            error.status_code = msg.status_code;

            switch (msg.status_code) {
                case Soup.Status.BAD_REQUEST:
                    throw new BadStatusCodeError.BAD_REQUEST (error.msg);
                case Soup.Status.NOT_FOUND:
                    throw new BadStatusCodeError.NOT_FOUND (error.msg);
                case Soup.Status.FORBIDDEN:
                    throw new BadStatusCodeError.UNAUTHORIZE_ERROR (error.msg);
                default:
                    throw new BadStatusCodeError.UNKNOWN (msg.status_code.to_string () + ": " + error.msg);
            }
        }

        Bytes run_sync (Message msg) throws ClientError, BadStatusCodeError {
            Bytes bytes = null;

            try {
                bytes = session.send_and_read (msg);

            } catch (Error e) {
                throw new ClientError.SOUP_ERROR ("%s %s: %s".printf (
                    msg.method,
                    msg.uri.to_string (),
                    e.message
                ));
            }

            check_status_code (msg, bytes);

            return bytes;
        }

        async Bytes? run_async (
            Message msg,
            int priority
        ) throws ClientError, BadStatusCodeError {
            Bytes bytes = null;

            try {
                bytes = yield session.send_and_read_async (msg, priority, null);

            } catch (Error e) {
                throw new ClientError.SOUP_ERROR ("%s %s: %s".printf (
                    msg.method,
                    msg.uri.to_string (),
                    e.message
                ));
            }

            check_status_code (msg, bytes);

            return bytes;
        }

        public Bytes get_sync (
            owned string uri,
            string[]? header_preset_names = null,
            string[,]? parameters = null,
            Header[]? headers = null
        ) throws ClientError, BadStatusCodeError {
            var msg = message_get (uri, header_preset_names, parameters, headers);

            return run_sync (msg);
        }

        public async Bytes get_async (
            owned string uri,
            string[]? header_preset_names = null,
            string[,]? parameters = null,
            Header[]? headers = null,
            int priority = 0
        ) throws ClientError, BadStatusCodeError {
            var msg = message_get (uri, header_preset_names, parameters, headers);

            return yield run_async (msg, priority);
        }

        public Bytes post_sync (
            owned string uri,
            string[]? header_preset_names = null,
            PostContent? post_content = null,
            string[,]? parameters = null,
            Header[]? headers = null
        ) throws ClientError, BadStatusCodeError {
            var msg = message_post (uri, header_preset_names, post_content, parameters, headers);

            return run_sync (msg);
        }

        public async Bytes post_async (
            owned string uri,
            string[]? header_preset_names = null,
            PostContent? post_content = null,
            string[,]? parameters = null,
            Header[]? headers = null,
            int priority = Priority.DEFAULT
        ) throws ClientError, BadStatusCodeError {
            var msg = message_post (uri, header_preset_names, post_content, parameters, headers);

            return yield run_async (msg, priority);
        }
    }
}
