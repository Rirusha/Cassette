/*
 * Copyright (C) 2024-2026 Vladimir Romanov <rirusha@altlinux.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Tape.YaMAPI.Rotor;
using ApiBase;
using Serialize;

public sealed class Tape.YaMAPI.Client : Object {

    const string USER_AGENT = "libtape";
    const string YAM_BASE_URL = "https://api.music.yandex.net";

    public Session session { private get; construct; }

    public AuthType auth_type { get; construct; }

    public string token { internal get; private set construct; default = ""; }

    public Account.About? me { get; private set; default = null; }

    public string? cookies_path { get; construct; default = null; }

    public CookieJarType cookie_jar_type { get; construct; default = NONE; }

    public bool is_init_complete {
        get {
            return me != null;
        }
    }

    Client () {}

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

    public Client.with_token (string token) {
        Object (
            session: new Session () {
                user_agent = USER_AGENT
            },
            token: token,
            auth_type: AuthType.TOKEN
        );
    }

    public Client.with_cookie (string cookie_path, CookieJarType cookie_jar_type) {
        AuthType auth_type;
        switch (cookie_jar_type) {
            case DB:
                auth_type = COOKIES_DB;
                break;

            case TEXT:
                auth_type = COOKIES_TEXT;
                break;

            default:
                assert_not_reached ();
        }

        Object (
            session: new Session () {
                user_agent = USER_AGENT
            },
            cookie_jar_type: cookie_jar_type,
            cookies_path: cookie_path,
            auth_type: auth_type
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

    public void abort () {
        session.abort ();
    }

    public void reload_cookies () {
        if (cookies_path != null && cookie_jar_type != NONE) {
            session.init_cookies (cookie_jar_type, cookies_path);
        }
    }

    public async void init (
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError, CantUseError {
        if (auth_type != TOKEN) {
            var datalist = Datalist<string> ();
            datalist.set_data ("grant_type", "sessionid");
            datalist.set_data ("client_id", "23cabbbdc6cd418abb4b39c32c41195d");
            datalist.set_data ("client_secret", "53bc75238f0c4d08a118e51fe9203300");
            datalist.set_data ("host", "oauth.yandex.ru");

            Content post_content = { ApiBase.ContentType.X_WWW_FORM_URLENCODED };
            post_content.set_datalist (datalist);

            var request = new Request.POST ("https://oauth.yandex.ru/token");
            request.add_content (post_content);

            try {
                var bytes = yield session.send_and_read_async (request, priority, cancellable);

                var jsoner = new JsonWorker.from_bytes (
                    bytes,
                    { "access_token" },
                    new Serialize.Settings () { names_case = Serialize.Case.SNAKE }
                );

                var val = jsoner.deserialize_value ();

                if (val.type () == Type.STRING) {
                    token = val.get_string ();
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

            me = yield account_about (priority, cancellable);
            if (me != null) {
                if (!me.has_plus) {
                    throw new CantUseError.NO_PLUS ("No Plus Subscription");
                }
            }
        } else {
            throw new TapeError.INTERNAL (_("No token provided"));
        }
    }

    /**
     * Получит содержимое по url
     *
     * @param url   url, по котором нужно получить контент
     *
     * @return      контент в байтах
     */
    public async Bytes? get_content_of (
        string url,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        try {
            return yield session.send_and_read_async (new Request.GET (url), priority, cancellable);
        } catch (GLib.Error e) {
            handle_error (e);
        }
    }

    string fix_uid (string? uid) throws TapeError {
        if (uid != null) {
            return uid;
        }

        if (me != null) {
            return me.uid;
        }

        throw new TapeError.INTERNAL (_("Authorization not completed"));
    }

    /**
     *
     */
    public async void account_experiments () throws TapeError, BadStatusCodeError {
        assert_not_reached ();
    }

    /**
     *
     */
    public async void account_experiments_details () throws TapeError, BadStatusCodeError {
        assert_not_reached ();
    }

    /**
     *
     */
    public async void account_settings () throws TapeError, BadStatusCodeError {
        assert_not_reached ();
    }

    /**
     * Получение информации о текущем пользователе
     */
    public async Account.About account_about (
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

            var jsoner = new JsonWorker.from_bytes (bytes, { "result" });

            return yield jsoner.deserialize_object_async<Account.About> ();
        } catch (GLib.Error e) {
            handle_error (e);
        }
    }

    /**
     *
     */
    public async void albums_with_tracks (
        string album_id,
        bool rich_tracks,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        assert_not_reached ();
    }

    /**
     *
     */
    public async Playlist playlist (
        string playlist_uuid,
        bool resume_stream,
        bool rich_tracks,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        var request = new Request.GET (@"/playlist/$playlist_uuid");
        request.presets = { "default" };
        request.add_param ("resumeStream", resume_stream.to_string ());
        request.add_param ("richTracks", rich_tracks.to_string ());

        try {
            var bytes = yield session.send_and_read_async (
                request,
                priority,
                cancellable
            );
            var jsoner = new JsonWorker.from_bytes (bytes, { "result" });

            return yield jsoner.deserialize_object_async<Playlist> ();
        } catch (GLib.Error e) {
            handle_error (e);
        }
    }

    /**
     *
     */
    public async void playlists (
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        assert_not_reached ();
    }

    /**
     *
     */
    public async void artists_tracks (
        string artist_id,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        assert_not_reached ();
    }

    /**
     *
     */
    public async void artists_track_ids (
        string artist_id,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        assert_not_reached ();
    }

    /**
     *
     */
    public async void artists_safe_direct_albums (
        string artist_id,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        assert_not_reached ();
    }

    /**
     *
     */
    public async void artists_brief_info (
        string artist_id,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        assert_not_reached ();
    }

    /**
     *
     */
    public async void artists_similar (
        string artist_id,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        assert_not_reached ();
    }

    /**
     *
     */
    public async void artists_discography_albums (
        string artist_id,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        assert_not_reached ();
    }

    /**
     *
     */
    public async void artists_direct_albums (
        string artist_id,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        assert_not_reached ();
    }

    /**
     *
     */
    public async void artists_also_albums (
        string artist_id,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        assert_not_reached ();
    }

    /**
     *
     */
    public async void artists_concerts (
        string artist_id,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        assert_not_reached ();
    }

    /**
     *
     */
    public async void users_playlists_list_kinds (
        string? uid = null,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        var real_uid = fix_uid (uid);
    }

    /**
     *
     */
    public async void users_playlists (
        string? uid = null,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        var real_uid = fix_uid (uid);
    }

    /**
     *
     */
    public async Serialize.Array<Playlist> users_playlists_list (
        string? uid = null,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, JsonError,
    BadStatusCodeError {
        var real_uid = fix_uid (uid);

        var request = new Request.GET (@"/users/$real_uid/playlists/list");
        request.presets = { "default" };

        try {
            Bytes bytes = yield session.send_and_read_async (
                request,
                priority,
                cancellable
            );
            var jsoner = new JsonWorker.from_bytes (bytes, { "result" });

            return yield jsoner.deserialize_array_async<Playlist> ();
        } catch (GLib.Error e) {
            handle_error (e);
        }
    }

    /**
     *
     */
    public async Playlist users_playlists_playlist (
        string playlist_kind,
        bool rich_tracks,
        string? uid = null,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        var real_uid = fix_uid (uid);

        var request = new Request.GET (@"/users/$real_uid/playlists/$playlist_kind");
        request.presets = { "default" };
        request.add_param ("richTracks", rich_tracks.to_string ());

        try {
            var bytes = yield session.send_and_read_async (
                request,
                priority,
                cancellable
            );
            var jsoner = new JsonWorker.from_bytes (bytes, { "result" });

            return yield jsoner.deserialize_object_async<Playlist> ();
        } catch (GLib.Error e) {
            handle_error (e);
        }
    }

    /**
     *
     */
    public async void users_playlists_playlist_change_relative (
        string playlist_kind,
        string? uid = null,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        var real_uid = fix_uid (uid);
    }

    public async bool users_playlists_delete (
        string? uid,
        string kind,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        var real_uid = fix_uid (uid);

        var request = new Request.POST (@"/users/$real_uid/playlists/$kind/delete");
        request.presets = { "default" };

        try {
            Bytes bytes = yield session.send_and_read_async (
                request,
                priority,
                cancellable
            );

            var jsoner = new JsonWorker.from_bytes (bytes, { "result" });
            //  FIXME: Fix it
            //  if (jsoner.root != null) {
            //      return true;
            //  }
            return false;
        } catch (GLib.Error e) {
            handle_error (e);
        }
    }

    public async Playlist users_playlists_change (
        string? uid,
        string kind,
        string diff,
        int revision = 1,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        var real_uid = fix_uid (uid);

        var datalist = Datalist<string> ();
        datalist.set_data ("kind", kind);
        datalist.set_data ("revision", revision.to_string ());
        datalist.set_data ("diff", diff);

        Content post_content = { ApiBase.ContentType.X_WWW_FORM_URLENCODED };
        post_content.set_datalist (datalist);

        var request = new Request.POST (@"/users/$real_uid/playlists/$kind/change");
        request.presets = { "default" };
        request.add_content (post_content);

        try {
            Bytes bytes = yield session.send_and_read_async (
                request,
                priority,
                cancellable
            );

            var jsoner = new JsonWorker.from_bytes (bytes, { "result" });

            return yield jsoner.deserialize_object_async<Playlist> ();
        } catch (GLib.Error e) {
            handle_error (e);
        }
    }

    public async Playlist users_playlists_create (
        string? uid,
        string title,
        PlaylistVisible visibility = PlaylistVisible.PRIVATE,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        var real_uid = fix_uid (uid);

        var datalist = Datalist<string> ();
        datalist.set_data ("title", title);
        datalist.set_data ("visibility", visibility.to_string ());

        Content post_content = { ApiBase.ContentType.X_WWW_FORM_URLENCODED };
        post_content.set_datalist (datalist);

        var request = new Request.POST (@"/users/$real_uid/playlists/create");
        request.presets = { "default" };
        request.add_content (post_content);

        try {
            Bytes bytes = yield session.send_and_read_async (
                request,
                priority,
                cancellable
            );

            var jsoner = new JsonWorker.from_bytes (bytes, { "result" });

            return yield jsoner.deserialize_object_async<Playlist> ();
        } catch (GLib.Error e) {
            handle_error (e);
        }
    }

    public async Playlist users_playlists_name (
        string? uid,
        string kind,
        string new_name,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        var real_uid = fix_uid (uid);

        var datalist = Datalist<string> ();
        datalist.set_data ("value", new_name);

        Content post_content = { ApiBase.ContentType.X_WWW_FORM_URLENCODED };
        post_content.set_datalist (datalist);

        var request = new Request.POST (@"/users/$real_uid/playlists/$kind/name");
        request.presets = { "default" };
        request.add_content (post_content);

        try {
            Bytes bytes = yield session.send_and_read_async (
                request,
                priority,
                cancellable
            );

            var jsoner = new JsonWorker.from_bytes (bytes, { "result" });

            return yield jsoner.deserialize_object_async<Playlist> ();
        } catch (GLib.Error e) {
            handle_error (e);
        }
    }

    public async PlaylistRecommendations users_playlists_recommendations (
        string? uid,
        string kind,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        var real_uid = fix_uid (uid);

        var request = new Request.GET (@"/users/$real_uid/playlists/$kind/recommendations");
        request.presets = { "default" };

        try {
            var bytes = yield session.send_and_read_async (
                request,
                priority,
                cancellable
            );

            var jsoner = new JsonWorker.from_bytes (bytes, { "result" });

            return yield jsoner.deserialize_object_async<PlaylistRecommendations> ();
        } catch (GLib.Error e) {
            handle_error (e);
        }
    }

    //  public async Playlist users_playlists_visibility (
    //      string? uid,
    //      string kind,
    //      string visibility,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);

    //      var datalist = Datalist<string> ();
    //      datalist.set_data ("value", visibility);

    //      PostContent post_content = { PostContentType.X_WWW_FORM_URLENCODED };
    //      post_content.set_datalist (datalist);

    //      Bytes bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/users/$uid/playlists/$kind/visibility",
    //          { "default" },
    //          post_content,
    //          null,
    //          null,
    //          priority,
    //          cancellable
    //      );

    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      return (Playlist) yield jsoner.deserialize_object_async (typeof (Playlist));
    //  }

    //  public async Playlist users_palylists_cover_upload (
    //      string? uid,
    //      string kind,
    //      uint8[] new_cover,
    //      string filename,
    //      string content_type,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);

    //      var post_builder = new StringBuilder ();

    //      post_builder.append (Uuid.string_random ());
    //      post_builder.append_printf ("Content-Disposition: form-data; name=\"image\"; filename=\"%s\"\n", filename);
    //      post_builder.append_printf ("Content-Type: %s\n", content_type);
    //      post_builder.append_printf ("Content-Length: %d\n", new_cover.length);
    //      post_builder.append ("\n");
    //      post_builder.append ((string) new_cover);

    //      PostContent post_content = { PostContentType.X_WWW_FORM_URLENCODED, post_builder.free_and_steal () };

    //      Bytes bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/users/$uid/playlists/$kind/cover/upload",
    //          { "default" },
    //          post_content,
    //          null,
    //          null,
    //          priority,
    //          cancellable
    //      );

    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      return (Playlist) yield jsoner.deserialize_object_async (typeof (Playlist));
    //  }

    //  public async Playlist users_palylists_cover_clear (
    //      string? uid,
    //      string kind,
    //      uint8[] new_cover,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);

    //      Bytes bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/users/$uid/playlists/$kind/cover/clear",
    //          { "default" },
    //          null,
    //          null,
    //          null,
    //          priority,
    //          cancellable
    //      );

    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      return (Playlist) yield jsoner.deserialize_object_async (typeof (Playlist));
    //  }

    //  /**
    //   *
    //   */
    //  public async void users_likes_albums (
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);
    //  }

    //  /**
    //   *
    //   */
    //  public async void users_likes_artists (
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);
    //  }

    //  /**
    //   *
    //   */
    //  public async Serialize.Array<LikedPlaylist> users_likes_playlists (
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);

    //      Bytes bytes = yield session.get_async (
    //          @"$(YAM_BASE_URL)/users/$uid/likes/playlists",
    //          { "default" },
    //          null,
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      var playlist_array = new Serialize.Array<LikedPlaylist> ();
    //      yield jsoner.deserialize_array_into_async (playlist_array);
    //      return playlist_array;
    //  }

    //  /**
    //   *
    //   */
    //  public async int64 users_likes_tracks_add (
    //      string track_id,
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);

    //      var bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/users/$uid/likes/tracks/add",
    //          { "default" },
    //          null,
    //          { { "track-id", track_id } },
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result", "revision" });

    //      var value = jsoner.deserialize_value ();

    //      if (value.type () == Type.INT64) {
    //          return value.get_int64 ();
    //      }
    //      return 0;
    //  }

    //  /**
    //   *
    //   */
    //  public async int64 users_likes_tracks_remove (
    //      string track_id,
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);

    //      var bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/users/$uid/likes/tracks/$track_id/remove",
    //          { "default" },
    //          null,
    //          null,
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result", "revision" });

    //      var value = jsoner.deserialize_value ();

    //      if (value.type () == Type.INT64) {
    //          return value.get_int64 ();
    //      }
    //      return 0;
    //  }

    //  public async Serialize.Array<TrackShort> users_dislikes_tracks (
    //      string? uid,
    //      int if_modified_since_revision = 0,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws SoupError, JsonError,
    //  BadStatusCodeError {
    //      var real_uid = fix_uid (uid);

    //      var bytes = yield session.get_async (
    //          @"$(YAM_BASE_URL)/users/$uid/dislikes/tracks",
    //          { "default" },
    //          {
    //              { "if_modified_since_revision", if_modified_since_revision.to_string () }
    //          },
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result", "library", "tracks" });

    //      var our_array = new Serialize.Array<TrackShort> ();
    //      yield jsoner.deserialize_array_into_async (our_array);

    //      return our_array;
    //  }

    //  /**
    //   *
    //   */
    //  public async int64 users_dislikes_tracks_add (
    //      string track_id,
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);

    //      var bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/users/$uid/dislikes/tracks/add",
    //          { "default" },
    //          null,
    //          {
    //              { "track-id", track_id }
    //          },
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result", "revision" });

    //      var value = jsoner.deserialize_value ();

    //      if (value.type () == Type.INT64) {
    //          return value.get_int64 ();
    //      }
    //      return 0;
    //  }

    //  /**
    //   *
    //   */
    //  public async int64 users_dislikes_tracks_remove (
    //      string track_id,
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);

    //      var bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/users/$uid/dislikes/tracks/$track_id/remove",
    //          { "default" },
    //          null,
    //          null,
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result", "revision" });

    //      var value = jsoner.deserialize_value ();

    //      if (value.type () == Type.INT64) {
    //          return value.get_int64 ();
    //      }
    //      return 0;
    //  }

    //  /**
    //   *
    //   */
    //  public async bool users_likes_artists_add (
    //      string artist_id,
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);

    //      var bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/users/$uid/likes/artists/add",
    //          { "default" },
    //          null,
    //          {
    //              { "artist-id", artist_id }
    //          },
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      var value = jsoner.deserialize_value ();

    //      if (value.type () == Type.STRING) {
    //          return value.get_string () == "ok";
    //      }
    //      return false;
    //  }

    //  /**
    //   *
    //   */
    //  public async bool users_likes_artists_remove (
    //      string artist_id,
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);

    //      var bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/users/$uid/likes/artists/$artist_id/remove",
    //          { "default" },
    //          null,
    //          null,
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      var value = jsoner.deserialize_value ();

    //      if (value.type () == Type.STRING) {
    //          return value.get_string () == "ok";
    //      }
    //      return false;
    //  }

    //  /**
    //   *
    //   */
    //  public async bool users_dislikes_artists_add (
    //      string artist_id,
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);

    //      var bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/users/$uid/dislikes/artists/add",
    //          { "default" },
    //          null,
    //          {
    //              { "artist-id", artist_id }
    //          },
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      var value = jsoner.deserialize_value ();

    //      if (value.type () == Type.STRING) {
    //          return value.get_string () == "ok";
    //      }
    //      return false;
    //  }

    //  /**
    //   *
    //   */
    //  public async bool users_dislikes_artists_remove (
    //      string artist_id,
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);

    //      var bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/users/$uid/dislikes/artists/$artist_id/remove",
    //          { "default" },
    //          null,
    //          null,
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      var value = jsoner.deserialize_value ();

    //      if (value.type () == Type.STRING) {
    //          return value.get_string () == "ok";
    //      }
    //      return false;
    //  }

    //  /**
    //   *
    //   */
    //  public async bool users_likes_albums_add (
    //      string album_id,
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);

    //      var bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/users/$uid/likes/albums/add",
    //          { "default" },
    //          null,
    //          {
    //              { "album-id", album_id }
    //          },
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      var value = jsoner.deserialize_value ();

    //      if (value.type () == Type.STRING) {
    //          return value.get_string () == "ok";
    //      }
    //      return false;
    //  }

    //  /**
    //   *
    //   */
    //  public async bool users_likes_albums_remove (
    //      string album_id,
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);

    //      var bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/users/$uid/likes/albums/$album_id/remove",
    //          { "default" },
    //          null,
    //          null,
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      var value = jsoner.deserialize_value ();

    //      if (value.type () == Type.STRING) {
    //          return value.get_string () == "ok";
    //      }
    //      return false;
    //  }

    //  /**
    //   *
    //   */
    //  public async bool users_likes_playlists_add (
    //      string playlist_uid,
    //      string owner_uid,
    //      string playlist_kind,
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);

    //      var bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/users/$uid/likes/playlists/add",
    //          { "default" },
    //          null,
    //          {
    //              { "playlist-uuid", playlist_uid },
    //              { "owner-uid", owner_uid },
    //              { "kind", playlist_kind }
    //          },
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      var value = jsoner.deserialize_value ();

    //      if (value.type () == Type.STRING) {
    //          return value.get_string () == "ok";
    //      }
    //      return false;
    //  }

    //  /**
    //   *
    //   */
    //  public async bool users_likes_playlists_remove (
    //      string playlist_uid,
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);

    //      var bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/users/$uid/likes/playlists/$playlist_uid/remove",
    //          { "default" },
    //          null,
    //          null,
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      var value = jsoner.deserialize_value ();

    //      if (value.type () == Type.STRING) {
    //          return value.get_string () == "ok";
    //      }
    //      return false;
    //  }

    //  /**
    //   *
    //   */
    //  public async void users_presaves_add (
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);
    //  }

    //  /**
    //   *
    //   */
    //  public async void users_presaves_remove (
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);
    //  }

    //  /**
    //   *
    //   */
    //  public async void users_search_history (
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);
    //  }

    //  /**
    //   *
    //   */
    //  public async void users_search_history_clear (
    //      string? uid = null,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var real_uid = fix_uid (uid);
    //  }

    /**
     * Получение данных о библиотеке пользователя
     */
    public async Library.AllIds library_all_ids (
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        var request = new Request.GET ("/library/all-ids");
        request.presets = { "default" };

        try {
            var bytes = yield session.send_and_read_async (
                request,
                priority,
                cancellable
            );

            var jsoner = new JsonWorker.from_bytes (bytes, { "result" });

            return yield jsoner.deserialize_object_async<Library.AllIds> ();
        } catch (GLib.Error e) {
            handle_error (e);
        }
    }

    //  /**
    //   *
    //   */
    //  public async void landing3_metatags (
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   *
    //   */
    //  public async void metatags_metatag (
    //      string metatag,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   *
    //   */
    //  public async void metatags_albums (
    //      string metatag,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   *
    //   */
    //  public async void metatags_artists (
    //      string metatag,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   *
    //   */
    //  public async void metatags_playlists (
    //      string metatag,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   *
    //   */
    //  public async void top_category (
    //      string category,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   *
    //   */
    //  public async void rotor_station_info (
    //      string station_id,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   *
    //   */
    //  public async void rotor_station_stream (
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   *
    //   */
    //  public async StationTracks rotor_session_new (
    //      SessionNew session_new,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      PostContent post_content = {
    //          PostContentType.JSON,
    //          yield ApiBase.Jsoner.serialize_async (session_new)
    //      };

    //      Bytes bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/rotor/session/new",
    //          { "default" },
    //          post_content,
    //          null,
    //          null,
    //          priority,
    //          cancellable
    //      );

    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      return (StationTracks) yield jsoner.deserialize_object_async (typeof (StationTracks));
    //  }

    //  /**
    //   *
    //   */
    //  public async StationTracks rotor_session_tracks (
    //      string radio_session_id,
    //      Rotor.Queue queue,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      PostContent post_content = {
    //          PostContentType.JSON,
    //          yield ApiBase.Jsoner.serialize_async (queue)
    //      };

    //      Bytes bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/rotor/session/$radio_session_id/tracks",
    //          { "default" },
    //          post_content,
    //          null,
    //          null,
    //          priority,
    //          cancellable
    //      );

    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      return (StationTracks) yield jsoner.deserialize_object_async (typeof (StationTracks));
    //  }

    //  /**
    //   *
    //   */
    //  public async void rotor_session_feedback (
    //      string radio_session_id,
    //      Rotor.Feedback feedback,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      PostContent post_content = {
    //          PostContentType.JSON,
    //          yield ApiBase.Jsoner.serialize_async (feedback)
    //      };

    //      yield session.post_async (
    //          @"$(YAM_BASE_URL)/rotor/session/$radio_session_id/feedback",
    //          { "default" },
    //          post_content,
    //          null,
    //          null,
    //          priority,
    //          cancellable
    //      );
    //  }

    //  /**
    //   * Метод для получения всех возможных настроек волны
    //   *
    //   * @return  объект `YaMAPI.Rotor.Settings`, содержащий все настройки
    //   */
    //  public async Rotor.Settings rotor_wave_settings (
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var bytes = yield session.get_async (
    //          @"$(YAM_BASE_URL)/rotor/wave/settings",
    //          { "default" },
    //          {
    //              { "language", get_language () }
    //          },
    //          null,
    //          priority,
    //          cancellable
    //      );

    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      return (Rotor.Settings) yield jsoner.deserialize_object_async (typeof (Rotor.Settings));
    //  }

    //  /**
    //   * Получение последней прослушиваемой волны текущим пользователем
    //   */
    //  public async Rotor.Wave rotor_wave_last (
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var bytes = yield session.get_async (
    //          @"$(YAM_BASE_URL)/rotor/wave/last",
    //          { "default" },
    //          {
    //              { "language", get_language () }
    //          },
    //          null,
    //          priority,
    //          cancellable
    //      );

    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      return (Wave) yield jsoner.deserialize_object_async (typeof (Wave));
    //  }

    //  /**
    //   * Сбросить значение последней прослушиваемой станции.
    //   *
    //   * @return  успех выполнения
    //   */
    //  public async bool rotor_wave_last_reset (
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/rotor/wave/last/reset",
    //          { "default" },
    //          null,
    //          null,
    //          null,
    //          priority,
    //          cancellable
    //      );

    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      if (jsoner.root == null) {
    //          return false;
    //      }

    //      return jsoner.deserialize_value ().get_string () == "ok";
    //  }

    //  public async Dashboard rotor_stations_dashboard (
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var bytes = yield session.get_async (
    //          @"$(YAM_BASE_URL)/rotor/stations/dashboard",
    //          { "default", "device" },
    //          {
    //              { "language", get_language () }
    //          },
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      return (Dashboard) yield jsoner.deserialize_object_async (typeof (Dashboard));
    //  }

    //  public async Serialize.Array<Station> rotor_stations_list (
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var bytes = yield session.get_async (
    //          @"$(YAM_BASE_URL)/rotor/stations/list",
    //          { "default", "device" },
    //          {
    //              { "language", get_language () }
    //          },
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      var sl_array = new Serialize.Array<Station> ();
    //      yield jsoner.deserialize_array_into_async (sl_array);

    //      return sl_array;
    //  }

    //  /**
    //   *
    //   */
    //  public async void search_feedback (
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   *
    //   */
    //  public async void search_instant_mixed (
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   * Метод отправки фидбека о прослушивании трека.
    //   *
    //   * @param play_id               id сессии прослушивания
    //   * @param total_played_seconds  общее количество прослушанного времени в секундах
    //   * @param end_position_seconds  секунда, на которой закончилось прослушивание
    //   * @param track_length_seconds  общее количество секунд в треке
    //   * @param track_id              id трека
    //   * @param album_id              id вльбома, может быть `null`
    //   * @param from
    //   * @param context               контекст воспроизведения (То же что и `Queue.context.type`)
    //   * @param context_item          id контекста, (Тоже же, что и `Queue.context.id`)
    //   * @param radio_session_id      id сессии волны
    //   *
    //   * @return                      успех выполнения
    //   */
    //  public async bool plays (
    //      Play[] play_objs,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var plays_obj = new Plays ();
    //      plays_obj.plays.add_all_array (play_objs);

    //      PostContent post_content = {
    //          PostContentType.JSON,
    //          yield ApiBase.Jsoner.serialize_async (plays_obj)
    //      };

    //      Bytes bytes = yield session.post_async (
    //          @"$(YAM_BASE_URL)/plays",
    //          { "default" },
    //          post_content,
    //          {
    //              { "clientNow", get_timestamp () }
    //          },
    //          null,
    //          priority,
    //          cancellable
    //      );

    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      if (jsoner.root == null) {
    //          return false;
    //      }

    //      return jsoner.deserialize_value ().get_string () == "ok";
    //  }

    //  /**
    //   *
    //   */
    //  public async void rewind_slides_user (
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   *
    //   */
    //  public async void rewind_slides_artist (
    //      string artist_id,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   *
    //   */
    //  public async void pins (
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   *
    //   */
    //  public async void pins_albums (
    //      bool pin,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   *
    //   */
    //  public async void pins_playlist (
    //      bool pin,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   *
    //   */
    //  public async void pins_artist (
    //      bool pin,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   *
    //   */
    //  public async void pins_wave (
    //      bool pin,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   *
    //   */
    //  public async void tags_playlist_ids (
    //      string tag_id,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    //  /**
    //   *
    //   */
    //  public async void feed_promotions_promo (
    //      string promo_id,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      assert_not_reached ();
    //  }

    public async Serialize.Array<Track> tracks (
        string[] id_list,
        bool with_positions = false,
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        var datalist = Datalist<string> ();
        datalist.set_data ("track-ids", string.joinv (",", id_list));
        datalist.set_data ("with-positions", with_positions.to_string ());

        Content post_content = { ApiBase.ContentType.X_WWW_FORM_URLENCODED };
        post_content.set_datalist (datalist);

        var request = new Request.POST ("/tracks");
        request.presets = { "default" };
        request.add_content (post_content);

        try {
            var bytes = yield session.send_and_read_async (
                request,
                priority,
                cancellable
            );
            var jsoner = new JsonWorker.from_bytes (bytes, { "result" });

            return yield jsoner.deserialize_array_async<Track> ();
        } catch (GLib.Error e) {
            handle_error (e);
        }
    }

    //  public async string track_download_url (
    //      string track_id,
    //      bool hq = true,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      var di_array = yield tracks_download_info (
    //          track_id,
    //          priority,
    //          cancellable
    //      );

    //      int bitrate = hq ? 0 : 500;
    //      string dl_info_uri = "";
    //      foreach (DownloadInfo download_info in di_array) {
    //          if (hq == (bitrate < download_info.bitrate_in_kbps)) {
    //              bitrate = download_info.bitrate_in_kbps;
    //              dl_info_uri = download_info.download_info_url;
    //          }
    //      }

    //      return yield form_download_url (
    //          dl_info_uri,
    //          priority,
    //          cancellable
    //      );
    //  }

    //  public async Serialize.Array<DownloadInfo> tracks_download_info (
    //      string track_id,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      Bytes bytes = yield session.get_async (
    //          @"$(YAM_BASE_URL)/tracks/$track_id/download-info",
    //          { "default" },
    //          null,
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      var di_array = new Serialize.Array<DownloadInfo> ();
    //      yield jsoner.deserialize_array_into_async (di_array);

    //      return di_array;
    //  }

    //  async string form_download_url (
    //      string dl_info_url,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      Bytes bytes = yield get_content_of (
    //          dl_info_url,
    //          priority,
    //          cancellable
    //      );
    //      string xml_string = (string) bytes.get_data ();

    //      Xml.Parser.init ();
    //      var doc = Xml.Parser.parse_memory (xml_string, xml_string.length);

    //      var root = doc->get_root_element ();

    //      var children = root->children;
    //      var host = children->get_content ();

    //      children = children->next;
    //      var path = children->get_content ();

    //      children = children->next;
    //      var ts = children->get_content ();

    //      children = children->next;
    //      children = children->next;
    //      var s = children->get_content ();

    //      var str = "XGRlBW9FXlekgbPrRHuSiA" + path[1:] + s;
    //      var sign = Checksum.compute_for_string (ChecksumType.MD5, str, str.length);

    //      return @"https://$host/get-mp3/$sign/$ts/$path";
    //  }

    //  public async Lyrics track_lyrics (
    //      string track_id,
    //      bool is_sync,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      string format = is_sync ? "LRC" : "TEXT";
    //      string timestamp = new DateTime.now_utc ().to_unix ().to_string ();
    //      string msg = @"$track_id$timestamp";

    //      var hmac = new Hmac (ChecksumType.SHA256, "p93jhgh689SBReK6ghtw62".data);
    //      hmac.update (msg.data);
    //      uint8[] hmac_sign = new uint8[32];
    //      size_t digest_length = 32;
    //      hmac.get_digest (hmac_sign, ref digest_length);
    //      string sign = Base64.encode (hmac_sign);

    //      Bytes bytes = yield session.get_async (
    //          @"$(YAM_BASE_URL)/tracks/$track_id/lyrics",
    //          { "default" },
    //          {
    //              { "format", format },
    //              { "timeStamp", timestamp },
    //              { "sign", sign }
    //          },
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      var lyrics = (Lyrics) yield jsoner.deserialize_object_async (typeof (Lyrics));
    //      lyrics.is_sync = is_sync;

    //      return lyrics;
    //  }

    //  public async SimilarTracks tracks_similar (
    //      string track_id,
    //      int priority = Priority.DEFAULT,
    //      Cancellable? cancellable = null
    //  ) throws TapeError, BadStatusCodeError {
    //      Bytes bytes = yield session.get_async (
    //          @"$(YAM_BASE_URL)/tracks/$track_id/similar",
    //          { "default" },
    //          null,
    //          null,
    //          priority,
    //          cancellable
    //      );
    //      var jsoner = new Jsoner.from_bytes (bytes, { "result" });

    //      return (SimilarTracks) yield jsoner.deserialize_object_async (typeof (SimilarTracks));
    //  }
}
