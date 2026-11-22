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

public partial sealed class Tape.YandexMusic {

    async Tape.SyncData sync (
        int priority = Priority.DEFAULT,
        Cancellable? cancellable = null
    ) throws TapeError, BadStatusCodeError {
        var request = new Request.GET ("/sync");
        request.presets = { "default" };

        try {
            return yield session.send_and_read_typed_async (
                request,
                new Tape.ResultCodec<Tape.SyncData> (
                    new Deser.ObjectCodec<Tape.SyncData> (),
                    "values"
                ),
                deser_settings,
                priority,
                cancellable
            );

        } catch (GLib.Error e) {
            handle_error (e);
        }
    }
}
