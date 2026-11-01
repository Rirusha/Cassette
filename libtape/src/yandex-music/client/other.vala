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
using Deser;

public partial sealed class Tape.YandexMusic {

    public signal void track_likes_start_change (string track_id);
    public signal void track_likes_end_change (string track_id, bool is_liked);

    public signal void track_dislikes_start_change (string track_id);
    public signal void track_dislikes_end_change (string track_id, bool is_disliked);

    // public signal void playlist_changed (Tape.Playlist new_playlist);
    public signal void playlists_updated ();
    public signal void playlist_start_delete (string oid);
    public signal void playlist_stop_delete (string oid);

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
}
