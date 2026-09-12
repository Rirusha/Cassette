/*
 * Copyright (C) 2026 Vladimir Romanov <rirusha@altlinux.org>
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

public sealed class Cassette.DevelActionGroup : SimpleActionGroup {

    construct {
        var play_test_track_action = new SimpleAction ("play-test-track", null);
        play_test_track_action.activate.connect (play_test_track);
        add_action (play_test_track_action);
    }

    void play_test_track () {
        var chooser = new Gtk.FileDialog ();
        chooser.open.begin (
            Application.instance.active_window,
            null,
            on_file_open_callback
        );
    }

    void on_file_open_callback (Object? obj, AsyncResult res) {
        try {
            var file = ((Gtk.FileDialog) obj).open.end (res);

            if (file == null) {
                warning ("File not choosed");
                return;
            }

            Application.tape_client.player.play_file (file);
        } catch (Error e) {
            warning ("Can't open file: %s", e.message);
        }
    }
}
