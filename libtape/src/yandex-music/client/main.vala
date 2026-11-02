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

    Deser.Settings deser_settings = new Deser.Settings () {
        names_case = Deser.Case.CAMEL
    };

    public Tape.AccountAbout? me { get; private set; }

    public string? cookies_path { get; construct; default = null; }

    public CookieJarType cookie_jar_type { get; construct; default = NONE; }

    public bool inited {
        get {
            return me != null;
        }
    }

    internal YandexMusic (
        owned string? token = null
    ) {
        AuthType auth_type = NONE;
        CookieJarType cookie_jar_type = NONE;
        string? cookies_path = null;

        if (root.cm.storager.cookies_file.query_exists ()) {
            cookies_path = root.cm.storager.cookies_file.peek_path ();
        }

        if (token == null) {
            token = root.cm.storager.load_token ();
        }

        if (cookies_path != null) {
            auth_type = COOKIES_DB;
            cookie_jar_type = DB;

        } else if (token != null) {
            auth_type = TOKEN;
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
    void handle_error_with_usage (GLib.Error e) throws TapeError, BadStatusCodeError, CantUseError {
        if (e is CantUseError) {
            throw (CantUseError) e;
        }
        handle_error (e);
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

    async void ensure_init (
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError, CantUseError {
        if (!inited) {
            yield init (priority, cancellable);
        }
    }

    internal async void init (
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError, CantUseError {
        assert (!inited);

        if (auth_type == NONE) {
            throw new CantUseError.AUTH_REQUIRED (_("Authentication required"));
        }

        Error? thrown_e = null;
        int64 expires_at = 0;
        try {
            if (auth_type != TOKEN) {
                var datalist = Datalist<string> ();
                datalist.set_data ("grant_type", "sessionid");
                datalist.set_data ("client_id", "23cabbbdc6cd418abb4b39c32c41195d");
                datalist.set_data ("client_secret", "53bc75238f0c4d08a118e51fe9203300");
                datalist.set_data ("host", "oauth.yandex.ru");

                Session.Content post_content = { Session.ContentType.X_WWW_FORM_URLENCODED };
                post_content.set_datalist (datalist);

                var request = new Request.POST ("https://oauth.yandex.ru/token");
                request.add_content (post_content);

                var bytes = yield session.send_and_read_async (request, priority, cancellable);

                var init_settings = deser_settings.copy ();
                init_settings.names_case = SNAKE;
                var worker = new Deser.JsonWorker.from_bytes (
                    bytes,
                    init_settings
                );
                var init_data = yield worker.deserialize_async (
                    new Deser.ObjectCodec<Tape.Init> ()
                );

                token = init_data.access_token;
                expires_at = new DateTime.now_utc ().to_unix () + init_data.expires_in;
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

                me = yield get_account_about (priority, cancellable);
                if (me != null) {
                    if (!me.has_plus) {
                        throw new CantUseError.NO_PLUS (_("No Plus Subscription"));
                    }
                }
            }
        } catch (Error e) {
            thrown_e = e;
        }

        if (me == null) {
            string my_uid = root.cm.storager.db.get_additional_data ("me");
            if (my_uid != null) {
                me = (Tape.AccountAbout) root.cm.storager.load_object_sync (
                    typeof (Tape.AccountAbout),
                    my_uid
                );
            }

            if (me == null) {
                throw new CantUseError.AUTH_REQUIRED (_("Authentication required"));
            }
        }

        if (thrown_e != null) {
            handle_error_with_usage (thrown_e);
        }

        root.cm.storager.db.set_additional_data ("me", me.uid);
        yield root.cm.storager.save_object (me, false);

        if (auth_type == TOKEN) {
            root.cm.storager.save_token (token);
        }

        likes_handler.full_update (yield library_all_ids ());

        notify_property ("inited");
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

            var jsoner = new Deser.JsonWorker.from_bytes (bytes, deser_settings);

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
