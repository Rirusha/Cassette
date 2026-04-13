/*
 * Copyright (C) 2023-2026 Vladimir Romanov <rirusha@altlinux.org>
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
 * along with this program. If not, see
 * <https://www.gnu.org/licenses/gpl-3.0-standalone.html>.
 * 
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public sealed class CassetteDemo.Application : Adw.Application {

    const ActionEntry[] ACTION_ENTRIES = {
        { "quit", quit },
        { "test", }
    };

    const OptionEntry[] OPTION_ENTRIES = {
        { "version", 'v', 0, OptionArg.NONE, null, N_("Print version information and exit"), null },
        { null }
    };

    public Application () {
        Object (
            application_id: Config.APP_ID_RELEVANT,
            resource_base_path: @"/$(Config.APP_ID.replace (".", "/"))/",
            flags: ApplicationFlags.DEFAULT_FLAGS | ApplicationFlags.HANDLES_OPEN
        );
    }

    construct {
        add_main_option_entries (OPTION_ENTRIES);

        add_action_entries (ACTION_ENTRIES, this);
        set_accels_for_action ("app.quit", { "<primary>q" });
        set_accels_for_action ("app.test", { "<ctrl><shift>s" });
    }

    protected override int handle_local_options (VariantDict options) {
        if (options.contains ("version")) {
            print ("%s %s\n", Config.APP_NAME, Config.VERSION);
            return 0;
        }

        return -1;
    }

    public override void activate () {
        base.activate ();

        if (active_window == null) {
            Cassette.init ();
            var win = new Window (this);

            win.present ();
        } else {
            active_window.present ();
        }
    }
}
