/* Copyright 2023-2024 Rirusha
 *
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


using Cassette.Client.YaMAPI;
using Gee;

namespace Cassette.Client.Player {

    /**
     * Player mode with track list algorithms
     */
    public class PlayerTrackList : PlayerMode {

        ArrayList<YaMAPI.Track> original_queue = new ArrayList<YaMAPI.Track> ();

        public PlayerTrackList (
            Player player,
            ArrayList<YaMAPI.Track> queue,
            string context_type,
            string? context_id,
            int current_index,
            string? context_description
        ) {
            Object (
                player: player,
                queue: queue,
                context_type: context_type,
                context_id: context_id,
                current_index: current_index,
                context_description: context_description
            );
        }

        construct {
            original_queue.add_all (queue);

            if (player.shuffle_mode == ShuffleMode.ON) {
                shuffle ();
            }

            queue_post_action ();
        }

        void queue_post_action () {
            queue_changed (
                queue,
                context_type,
                context_id,
                current_index,
                context_description
            );
            near_changed (get_current_track_info ());
        }

        public void shuffle () {
            var type_utils = new TypeUtils<Track> ();

            var current_track = get_current_track_info ();

            ArrayList<Track> shuffled_queue = new ArrayList<Track> ();

            shuffled_queue.add_all (queue);
            queue.clear ();

            type_utils.shuffle (ref shuffled_queue);

            var new_index = shuffled_queue.index_of (current_track);

            queue.add_all (shuffled_queue[new_index:shuffled_queue.size]);
            queue.add_all (shuffled_queue[0:new_index]);

            current_index = 0;

            queue_post_action ();
        }

        public void unshuffle () {
            var current_track = get_current_track_info ();

            queue.clear ();
            queue.add_all (original_queue);
            current_index = queue.index_of (current_track);

            queue_post_action ();
        }

        public void add_track_next (YaMAPI.Track track_info) {
            if (queue.size == 0) {
                add_track_end (track_info);
                return;
            }

            queue.insert (current_index + 1, track_info);
            original_queue.insert (original_queue.index_of (get_current_track_info ()) + 1, track_info);

            queue_post_action ();
        }

        public void remove_track_by_pos (int position) {
            var track_info = queue[position];
            remove_track (track_info);
        }

        public void remove_track (Track track_info) {
            int track_pos = queue.index_of (track_info);

            if (track_pos == -1) {
                return;
            }

            queue.remove_at (track_pos);
            original_queue.remove (track_info);

            if (queue.size != 0) {
                if (track_pos == current_index) {
                    player.change_track (get_current_track_info ());

                } else if (track_pos < current_index) {
                    current_index--;
                }
            } else {
                player.stop ();
            }

            queue_post_action ();
        }

        public void remove_all_tracks () {
            queue.clear ();
            original_queue.clear ();
            current_index = -1;

            context_type = "various";

            player.stop ();

            queue_post_action ();
        }

        public void add_track_end (YaMAPI.Track track_info) {
            bool should_change_track_state = queue.size == 0;

            queue.add (track_info);
            original_queue.add (track_info);

            if (should_change_track_state) {
                player.start_current_track.begin (() => {
                    player.stop ();
                });
            }

            queue_post_action ();
        }

        public void add_many_end (ArrayList<YaMAPI.Track> track_list) {
            bool should_change_track_state = queue.size == 0;

            queue.add_all (track_list);
            original_queue.add_all (track_list);

            if (should_change_track_state) {
                player.start_current_track.begin (() => {
                    player.stop ();
                });
            }

            queue_post_action ();
        }

        public override async override YaMAPI.Track? get_prev_track_info_async () {
            if (queue.size > get_prev_index ()) {
                return queue[get_prev_index ()];
            } else {
                return null;
            }
        }

        public override YaMAPI.Track? get_current_track_info () {
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

        public override async override YaMAPI.Track? get_next_track_info_async () {
            if (queue.size > get_next_index (true)) {
                return queue[get_next_index (true)];
            } else {
                return null;
            }
        }

        public override void next (bool consider_repeat_mode) {
            current_index = get_next_index (consider_repeat_mode);

            queue_post_action ();
        }

        public int get_next_index (bool consider_repeat_one) {
            int index = current_index;

            switch (player.repeat_mode) {
                case RepeatMode.OFF:
                    if (index + 1 == queue.size) {
                        // Неразрешимая ситуация
                    } else {
                        index++;
                    }
                    break;

                case RepeatMode.REPEAT_ONE:
                    if (!consider_repeat_one) {
                        if (index + 1 == queue.size) {
                            // Неразрешимая ситуация
                        } else {
                            index++;
                        }
                    }
                    break;

                case RepeatMode.REPEAT_ALL:
                    if (index + 1 == queue.size) {
                        index = 0;
                    } else {
                        index++;
                    }
                    break;
            }

            return index;
        }

        public override void prev () {
            current_index = get_prev_index ();

            queue_post_action ();
        }

        public int get_prev_index () {
            int index = current_index;

            if (index - 1 == -1) {
                if (player.repeat_mode == RepeatMode.REPEAT_ONE || player.repeat_mode == RepeatMode.OFF) {
                    player.seek (0);
                } else {
                    index = queue.size - 1;
                }

            } else {
                index--;
            }

            return index;
        }

        public override YaMAPI.Play form_play_obj () {
            var current_track = get_current_track_info ();

            return new YaMAPI.Play () {
                track_length_seconds = ((double) current_track.duration_ms) / 1000.0,
                track_id = current_track.id,
                album_id = current_track.albums.size > 0 ? current_track.albums[0].id : null,
                context = context_type,
                context_item = context_id
            };
        }
    }
}
