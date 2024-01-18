/* player_track_list.vala
 *
 * Copyright 2023 Rirusha
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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


using CassetteClient.YaMAPI;
using Gee;

namespace CassetteClient.Player {
    public class PlayerTrackList : PlayerMode {

        YaMAPI.Queue _queue;
        public YaMAPI.Queue queue {
            get {
                return _queue;
            }
            set {
                _queue = value;

                original_tracks.clear ();
                original_tracks.add_all (_queue.tracks);

                _queue.tracks.clear ();
                _queue.tracks.add_all (original_tracks);

                if (player.shuffle_mode == ShuffleMode.ON) {
                    shuffle_without_emmit ();
                }

                near_changed ();

                send_queue.begin ();
                queue_changed (_queue);
            }
        }

        public signal void queue_changed (YaMAPI.Queue queue);

        ArrayList<YaMAPI.Track> original_tracks = new ArrayList<YaMAPI.Track> ();

        public Player player { get; construct; }

        public PlayerTrackList (Player player) {
            Object (player: player);
        }

        public bool change_track (YaMAPI.Track track_info) {
            for (int i = 0; i < _queue.tracks.size; i++) {
                if (_queue.tracks[i].id == track_info.id) {
                    _queue.current_index = i;
                    update_queue.begin ();

                    near_changed ();

                    return true;
                }
            }
            return false;
        }

        void shuffle_without_emmit () {
            var type_utils = new TypeUtils<Track> ();

            var current_track = get_current_track ();

            ArrayList<Track> track_list = _queue.tracks;
            type_utils.shuffle (ref track_list);

            var new_index = track_list.index_of (current_track);

            _queue.tracks = new ArrayList<YaMAPI.Track> ();
            _queue.tracks.add_all (track_list[new_index:track_list.size]);
            _queue.tracks.add_all (track_list[0:new_index]);

            _queue.current_index = 0;
        }

        public void shuffle () {
            shuffle_without_emmit ();

            send_queue.begin ();

            near_changed ();

            queue_changed (queue);
        }

        public void unshuffle () {
            var current_track = get_current_track ();

            _queue.tracks = new ArrayList<YaMAPI.Track> ();
            _queue.tracks.add_all (original_tracks);
            _queue.current_index = _queue.tracks.index_of (current_track);

            send_queue.begin ();

            near_changed ();

            queue_changed (queue);
        }

        async void send_queue () {
            var local_queue = queue;

            threader.add_single (() => {
                local_queue.id = yam_talker.create_queue (local_queue);
                if (local_queue.id == null) {
                    Logger.warning ("Can't create queue");
                }

                Idle.add (send_queue.callback);
            });

            yield;
        }

        async void update_queue () {
            var local_queue = queue;

            threader.add_single (() => {
                yam_talker.update_position_queue (local_queue);

                Idle.add (update_queue.callback);
            });

            yield;
        }

        public void add_track_next (YaMAPI.Track track_info) {
            if (_queue.tracks.size == 0) {
                add_track_end (track_info);
                return;
            }

            _queue.tracks.insert (_queue.current_index + 1, track_info);
            original_tracks.insert (original_tracks.index_of (get_current_track ()) + 1, track_info);

            send_queue.begin ();

            near_changed ();

            queue_changed (queue);
        }

        public void remove_track_by_pos (uint position) {
            message (position.to_string () + " : " + queue.tracks.size.to_string ());
            var track_info = _queue.tracks[(int) position];
            remove_track (track_info);
        }

        public void remove_track (Track track_info) {
            int track_pos = _queue.tracks.index_of (track_info);

            if (track_pos == -1) {
                return;
            }

            _queue.tracks.remove_at (track_pos);
            original_tracks.remove (track_info);

            if (_queue.tracks.size != 0) {
                if (track_pos == _queue.current_index) {
                    player.change_track (get_current_track ());
                } else if (track_pos < _queue.current_index) {
                    _queue.current_index--;
                }

                send_queue.begin ();
            } else {
                player.stop ();
            }

            near_changed ();

            queue_changed (queue);
        }

        public void remove_all_tracks () {
            _queue.tracks.clear ();
            _queue.context = new Context.various ();

            original_tracks.clear ();

            near_changed ();

            player.stop ();

            queue_changed (queue);
        }

        public void add_track_end (YaMAPI.Track track_info) {
            bool should_change_track_state = _queue.tracks.size == 0;

            _queue.tracks.add (track_info);
            original_tracks.add (track_info);

            send_queue.begin ();

            queue_changed (queue);

            if (should_change_track_state) {
                player.start_current_track.begin (() => {
                    player.stop ();
                });
            }

            near_changed ();
        }

        public void add_many_end (ArrayList<YaMAPI.Track> track_list) {
            bool should_change_track_state = _queue.tracks.size == 0;

            _queue.tracks.add_all (track_list);
            original_tracks.add_all (track_list);

            send_queue.begin ();

            queue_changed (queue);

            if (should_change_track_state) {
                player.start_current_track.begin (() => {
                    player.stop ();
                });
            }

            near_changed ();
        }

        public override async override YaMAPI.Track? get_prev_track () {
            if (_queue.tracks.size > get_prev_index ()) {
                return _queue.tracks[get_prev_index ()];
            } else {
                return null;
            }
        }

        public override override YaMAPI.Track? get_current_track () {
            if (_queue.tracks.size != 0) {
                if (_queue.current_index >= _queue.tracks.size) {
                    _queue.current_index = 0;
                    Logger.warning (_("Problems with queue"));
                }

                return _queue.tracks[_queue.current_index];
            } else {
                return null;
            }
        }

        public override async override YaMAPI.Track? get_next_track () {
            if (_queue.tracks.size > get_next_index (true)) {
                return _queue.tracks[get_next_index (true)];
            } else {
                return null;
            }
        }

        public override void next (bool consider_repeat_mode) {
            _queue.current_index = get_next_index (consider_repeat_mode);
            update_queue.begin ();

            near_changed ();
        }

        public int get_next_index (bool consider_repeat_one) {
            int index = _queue.current_index;

            switch (player.repeat_mode) {
                case RepeatMode.OFF:
                    if (index + 1 == _queue.tracks.size) {
                        // Неразрешимая ситуация
                    } else {
                        index++;
                    }
                    break;
                case RepeatMode.REPEAT_ONE:
                    if (!consider_repeat_one) {
                        if (index + 1 == _queue.tracks.size) {
                            // Неразрешимая ситуация
                        } else {
                            index++;
                        }
                    }
                    break;
                case RepeatMode.REPEAT_ALL:
                    if (index + 1 == _queue.tracks.size) {
                        index = 0;
                    } else {
                        index++;
                    }
                    break;
            }

            return index;
        }

        public override void prev () {
            _queue.current_index = get_prev_index ();
            update_queue.begin ();

            near_changed ();
        }

        public int get_prev_index () {
            int index = _queue.current_index;

            if (index - 1 == -1) {
                if (player.repeat_mode == RepeatMode.REPEAT_ONE || player.repeat_mode == RepeatMode.OFF) {
                    player.seek (0);
                } else {
                    index = _queue.tracks.size - 1;
                }

            } else {
                index--;
            }

            return index;
        }
    }
}
