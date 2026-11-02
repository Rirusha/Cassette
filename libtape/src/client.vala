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

    public bool local_only { get; construct; }

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

    public Client (Tape.Settings settings, bool local_only = false) {
        Object (settings: settings, local_only: local_only);
    }

    construct {
        root = this;

        cm = new CacheManager ();
        monitor.bind_property ("network-available", this, "network-available", SYNC_CREATE);
    }

    public async void init (string? yam_token = null) throws CantUseError {
        var ser_settings = Deser.get_settings ();
        ser_settings.names_case = Deser.Case.CAMEL;
        Deser.set_settings (ser_settings);

        string? token = yam_token;
        string? cookies_path = null;

        player = new Player ();
        // Mpris.init (this);

        if (!local_only) {
            ym = new YandexMusic (token);
            try {
                yield ym.init ();
            } catch (CantUseError e) {
                throw e;
            } catch (Error e) {
                // Auth data is good, so we pass client
            }
        }
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
