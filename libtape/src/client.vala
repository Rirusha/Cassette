/*
 * Copyright 2024 Vladimir Romanov
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

namespace Tape {
    internal static Client root;
}

[SingleInstance]
public class Tape.Client : Object {

    public Tape.Settings settings { get; construct; }

    /**
     * Cachier module.
     */
    public CacheManager cm { get; private set; }

    /**
     * YaMTalker module.
     */
    public YandexMusic ym { get; private set; }

    /**
     * Player module.
     */
    public Player player { get; private set; }

    public signal void quit ();

    public signal void raise ();

    public signal void mpris_uri_open (string uri);

    public bool network_available { get; protected set; }

    NetworkMonitor monitor = NetworkMonitor.get_default ();

    public Client (Tape.Settings settings) {
        Object (settings: settings);
    }

    construct {
        root = this;

        cm = new CacheManager ();
        monitor.bind_property ("network-available", this, "network-available", SYNC_CREATE);
    }

    public async bool init (string? yam_token = null) throws CantUseError, ApiBase.BadStatusCodeError, TapeError {
        var ser_settings = Serialize.get_settings ();
        ser_settings.names_case = Serialize.Case.CAMEL;
        Serialize.set_settings (ser_settings);

        string? token = yam_token;
        string? cookies_path = null;

        if (token == null) {
            if (cm.storager.cookies_file.query_exists ()) {
                cookies_path = cm.storager.cookies_file.peek_path ();
            } else {
                token = cm.storager.load_token ();
            }
        }

        if (token == null && cookies_path == null) {
            return false;
        }

        ym = new YandexMusic (
            cookies_path,
            token
        );

        player = new Player ();

        try {
            yield ym.init ();
        } catch (ApiBase.BadStatusCodeError e) {
            if (e is ApiBase.BadStatusCodeError.UNAUTHORIZED) {
                return false;
            } else {
                if (ym.can_be_offline ()) {
                    return true;
                }
                throw e;
            }
        } catch (TapeError e) {
            if (ym.can_be_offline ()) {
                return true;
            }
            throw e;
        }

        Mpris.init (this);

        if (ym.client.auth_type == TOKEN) {
            cm.storager.save_token (ym.client.token);
        }

        return true;
    }

    public void abort () {
        ym?.abort ();
    }

    public async void logout () {
        abort ();
        yield cm.white_list ();
        quit ();
    }
}
