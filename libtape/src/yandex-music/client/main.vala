/*
 * Copyright 2024-2026 Vladimir Romanov
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

using Session;

public partial sealed class Tape.YandexMusic : Object {

    const string USER_AGENT = "libtape";
    const string YAM_BASE_URL = "https://api.music.yandex.net";

    public Session.Session session { private get; construct; }

    public AuthType auth_type { get; construct; }

    public string token { internal get; internal set; default = ""; }

    Tape.AccountAbout? _me = null;
    public Tape.AccountAbout me {
        owned get {
            if (_me != null) {
                return _me;
            } else {
                string my_uid = root.cm.storager.db.get_additional_data ("me");
                if (my_uid != null) {
                    _me = (Tape.AccountAbout) root.cm.storager.load_object_sync (
                        typeof (Tape.AccountAbout),
                        my_uid
                    );
                }

                if (_me == null) {
                    return new Tape.AccountAbout ();
                }
            }

            return _me;
        }
    }

    public string? cookies_path { get; construct; default = null; }

    public CookieJarType cookie_jar_type { get; construct; default = NONE; }

    public bool inited {
        get {
            return _me != null;
        }
    }

    internal YandexMusic (
        string? cookies_path = null,
        string? token = null
    ) {
        assert ((cookies_path != null || token != null) && (cookies_path == null || token == null));

        AuthType auth_type;
        CookieJarType cookie_jar_type = NONE;

        if (cookies_path != null) {
            auth_type = COOKIES_DB;
            cookie_jar_type = DB;

        } else if (token != null) {
            auth_type = TOKEN;

        } else {
            assert_not_reached ();
        }

        Object (
            session: new Session.Session () {
                user_agent = USER_AGENT
            },
            token: token,
            auth_type: auth_type,
            cookie_jar_type: cookie_jar_type,
            cookies_path: cookies_path
        );
    }

    construct {
        reload_cookies ();

        session.add_base_url (YAM_BASE_URL);

        session.add_headers_preset (
            "device",
            {{
                "X-Yandex-Music-Device",
                "os=%s; os_version=%s; manufacturer=%s; model=%s; clid=; device_id=random; uuid=random".printf (
                    Environment.get_os_info (OsInfoKey.NAME),
                    Environment.get_os_info (OsInfoKey.VERSION),
                    "Cassette Dev Team",
                    "Yandex Music API"
                )
            }}
        );
    }

    [NoReturn]
    void handle_error (GLib.Error e) throws TapeError, BadStatusCodeError {
        if (e is BadStatusCodeError) {
            throw (BadStatusCodeError) e;
        }
        if (e is IOError.CANCELLED) {
            throw new TapeError.CANCELLED (e.message);
        }
        throw new TapeError.INTERNAL (e.message);
    }

    internal void abort () {
        session.abort ();
    }

    void reload_cookies () {
        if (cookies_path != null && cookie_jar_type != NONE) {
            session.init_cookies (cookie_jar_type, cookies_path);
        }
    }

    internal async void init (
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError, CantUseError {
        assert (!inited);

        if (auth_type != TOKEN) {
            var datalist = Datalist<string> ();
            datalist.set_data ("grant_type", "sessionid");
            datalist.set_data ("client_id", "23cabbbdc6cd418abb4b39c32c41195d");
            datalist.set_data ("client_secret", "53bc75238f0c4d08a118e51fe9203300");
            datalist.set_data ("host", "oauth.yandex.ru");

            Session.Content post_content = { Session.ContentType.X_WWW_FORM_URLENCODED };
            try {
                post_content.set_datalist (datalist);
            } catch (Deser.Error e) {
                handle_error (e);
            }

            var request = new Request.POST ("https://oauth.yandex.ru/token");
            request.add_content (post_content);

            try {
                var bytes = yield session.send_and_read_async (request, priority, cancellable);

                var parser = new Json.Parser ();
                parser.load_from_data ((string) bytes.get_data (), (ssize_t) bytes.get_size ());
                var root = parser.get_root ();
                if (root != null && root.get_node_type () == Json.NodeType.OBJECT &&
                    root.get_object ().has_member ("access_token")) {
                    token = root.get_object ().get_string_member ("access_token");
                }
            } catch (GLib.Error e) {
                handle_error (e);
            }
        }

        if (token != "") {
            session.add_headers_preset (
                "default",
                {
                    { "Authorization", @"OAuth $token" },
                    { "X-Yandex-Music-Client", "YandexMusicAndroid/24023231" }
                }
            );
            session.add_headers_preset (
                "auth",
                {
                    { "Authorization", @"OAuth $token" }
                }
            );

            _me = yield get_account_about (priority, cancellable);
            if (me != null) {
                if (!me.has_plus) {
                    throw new CantUseError.NO_PLUS ("No Plus Subscription");
                }
            }
        } else {
            throw new TapeError.INTERNAL (_("No token provided"));
        }

        root.cm.storager.db.set_additional_data ("me", me.uid);
        yield root.cm.storager.save_object (me, false);

        likes_handler.full_update (yield library_all_ids ());
    }

    async Tape.AccountAbout get_account_about (
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        var request = new Request.GET ("/account/about");
        request.presets = { "default" };

        try {
            var bytes = yield session.send_and_read_async (
                request,
                priority,
                cancellable
            );

            var jsoner = new Deser.JsonWorker.from_bytes (bytes);

            return yield jsoner.deserialize_async (
                new Tape.ResultCodec<Tape.AccountAbout> (
                    new Deser.ObjectCodec<Tape.AccountAbout> ()
                )
            );
        } catch (GLib.Error e) {
            handle_error (e);
        }
    }
}
