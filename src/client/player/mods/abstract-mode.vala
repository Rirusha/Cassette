/* Copyright 2023-2024 Vladimir Vaskov
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


using Gee;

/**
 * Abstract class of player mode.
 * Player can work with flow (radio), track list, local track list.
 * Every mode autoconnect to ``Player.queue_changed`` and
 * ``Player.nead_changed`` signals.
 */
public abstract class Cassette.Client.Player.Mode : Object {

    /**
     * Parent player object.
     */
    public Player player { get; construct; }

    public ArrayList<YaMAPI.Track> queue { get; construct; default = new ArrayList<YaMAPI.Track> (); }

    public string context_type { get; construct set; }

    public string? context_id { get; construct set; }

    public int current_index { get; construct set; default = -1; }

    public string? context_description { get; construct set; }

    construct {
        Logger.debug ("Created player mode");
        Logger.debug ("Context type: %s".printf (context_type));
        Logger.debug ("Context id: %s".printf (context_id));
        Logger.debug ("Current index: %d".printf (current_index));
        Logger.debug ("Context descriprion: %s".printf (context_description));
    }

    /**
     * Change current track to previous in queue.
     */
    public virtual void prev () {
        var new_index = get_prev_index ();

        if (new_index != -1) {
            current_index = new_index;
        }
    }

    /**
     * Get previous track index in queue.
     * Track list and Flow have different rules for this.
     *
     * @return  new index. Returns -1 if there's no previous track
     */
    public abstract int get_prev_index ();

    /**
     * Asynchronous getting previous track info.
     *
     * @return  track information object
     */
    public virtual YaMAPI.Track? get_prev_track_info () {
        var index = get_prev_index ();

        return index != -1 ? queue[index] : null;
    }

    /**
     * Get current track info.
     *
     * @return  track information object
     */
    public virtual YaMAPI.Track? get_current_track_info () {
        if (current_index != -1) {
            if (current_index >= queue.size) {
                current_index = 0;
                Logger.warning (_("Problems with queue"));
            }

            return queue[current_index];

        } else {
            return null;
        }
    }

    /**
     * Change current track to next.
     *
     * @param consider_repeat_mode  if ``true``, ignore repeat mode and go to next
     *                              else consider repeat
     */
    public virtual void next (bool consider_repeat_mode) {
        var new_index = get_next_index (consider_repeat_mode);

        if (new_index != -1) {
            current_index = new_index;
        }
    }

    /**
     * Get next track index in queue.
     * Track list and Flow have different rules for this.
     *
     * @param consider_repeat_mode  some mode ignore this.  
     *
     * @return  new index. Returns -1 if there's no next track
     */
    public abstract int get_next_index (bool consider_repeat_mode);

    /**
     * Asynchronous getting next track info.
     *
     * @return  track information object
     */
    public virtual YaMAPI.Track? get_next_track_info (bool consider_repeat_mode) {
        var index = get_next_index (consider_repeat_mode);

        return index != -1 ? queue[index] : null;
    }

    /**
     * Form Play object foe play feedback.
     *
     * @return  ``Cassette.Client.YaMAPI.Play`` object
     */
    protected abstract YaMAPI.Play form_play_obj ();

    public virtual async void send_play_async (
        string play_id,
        double end_position_seconds = 0.0,
        double total_played_seconds = 0.0
    ) {
        if (get_current_track_info () == null) {
            return;
        }

        var play_obj = form_play_obj ();

        play_obj.play_id = play_id;
        play_obj.end_position_seconds = end_position_seconds;
        play_obj.total_played_seconds = total_played_seconds;

        Logger.debug ("Track id %s: end: %f; total: %f, dur: %f".printf (
            play_obj.track_id,
            play_obj.end_position_seconds,
            play_obj.total_played_seconds,
            play_obj.track_length_seconds
        ));

        threader.add_single (() => {
            yam_talker.send_play ({play_obj});

            Idle.add (send_play_async.callback);
        });

        yield;
    }

    /**
     * Try to find track and play it.
     *
     * @param track_info    track information
     *
     * @return              `true` if track found and `false` otherwise
     */
    public bool change_track (YaMAPI.Track track_info) {
        for (int i = 0; i < queue.size; i++) {
            if (queue[i].id == track_info.id) {
                current_index = i;

                return true;
            }
        }

        return false;
    }
}
