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

    internal LikesModels likes_handler { get; default = new LikesModels (); }

    async Tape.YaMAPILibraryAllIds library_all_ids (
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

            var jsoner = new Deser.JsonWorker.from_bytes (bytes);

            return yield jsoner.deserialize_async (

                new Tape.ResultCodec<Tape.YaMAPILibraryAllIds> (

                    new Deser.ObjectCodec<Tape.YaMAPILibraryAllIds> ()

                )

            );
        } catch (GLib.Error e) {
            handle_error (e);
        }
    }
}
