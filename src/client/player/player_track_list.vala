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
    public class PlayerTL: Object, IPlayerMod {

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

                send_queue.begin ();
                player.queue_changed ();
            }
        }

      ArrayList<Track> original_tracks = new ArrayList<Track> ();

        public Track? current_track {
            owned get {
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
        }

        public Track next_track {
            owned get {
                return _queue.tracks[get_next_index ()];
            }
        }

        public Track prev_track {
            owned get {
                return _queue.tracks[get_prev_index ()];
            }
        }

        public Player player { get; construct; }

        public PlayerTL (Player player) {
            Object (player: player);
        }

        public void next () {
            _queue.current_index = get_next_index ();
            update_queue.begin ();
        }

        public int get_next_index () {
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

        public void prev () {
            _queue.current_index = get_prev_index ();
            update_queue.begin ();
        }

        public int get_prev_index () {
            int index = _queue.current_index;
            switch (player.repeat_mode) {
                case RepeatMode.OFF:
                    if (index - 1 == -1) {
                        player.seek (0);
                    } else {
                        index--;
                    }
                    break;
                case RepeatMode.REPEAT_ONE:
                    break;
                case RepeatMode.REPEAT_ALL:
                    if (index - 1 == -1) {
                        index = _queue.tracks.size - 1;
                    } else {
                        index--;;
                    }
                    break;
            }
            return index;
        }

        public bool change_track (Track track_info) {
            for (int i = 0; i < _queue.tracks.size; i++) {
                if (_queue.tracks[i].id == track_info.id) {
                    _queue.current_index = i;
                    update_queue.begin ();
                    return true;
                }
            }
            return false;
        }

      void shuffle_without_emmit () {
            var type_utils = new TypeUtils<Track> ();

            var track = current_track;

            ArrayList<Track> track_list = _queue.tracks;
            type_utils.shuffle (ref track_list);

            var new_index = track_list.index_of (track);

            _queue.tracks = new ArrayList<YaMAPI.Track> ();
            _queue.tracks.add_all (track_list[new_index:track_list.size]);
            _queue.tracks.add_all (track_list[0:new_index]);

            _queue.current_index = 0;
        }

        public void shuffle () {
            shuffle_without_emmit ();

            send_queue.begin ();
            player.queue_changed ();
        }

        public void unshuffle () {
            var track = current_track;

            _queue.tracks = new ArrayList<YaMAPI.Track> ();
            _queue.tracks.add_all (original_tracks);
            _queue.current_index = _queue.tracks.index_of (track);

            send_queue.begin ();
            player.queue_changed ();
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

        public void add_track_next (Track track_info) {
            if (_queue.tracks.size == 0) {
                add_track_end (track_info);
                return;
            }

            _queue.tracks.insert (_queue.current_index + 1, track_info);
            original_tracks.insert (original_tracks.index_of (current_track) + 1, track_info);

            send_queue.begin ();
            player.queue_changed ();
        }

        public void remove_track (uint position) {
            _queue.tracks.remove_at ((int) position);
            original_tracks.remove_at ((int) position);

            if (_queue.tracks.size != 0) {
                if (position == _queue.current_index) {
                    player.change_track (current_track);
                } else if (position < _queue.current_index) {
                    _queue.current_index--;
                }

                send_queue.begin ();
            } else {
                player.stop ();
            }

            player.queue_changed ();
        }

        public void remove_all_tracks () {
            _queue.tracks.clear ();
            _queue.context = new Context.various ();

            original_tracks.clear ();

            player.stop ();
            player.queue_changed ();
        }

        public void add_track_end (Track track_info) {
            bool should_change_track_state = _queue.tracks.size == 0;

            _queue.tracks.add (track_info);
            original_tracks.add (track_info);

            send_queue.begin ();
            player.queue_changed ();

            if (should_change_track_state) {
                player.start_current_track.begin (() => {
                    player.stop ();
                });
            }
        }

        public void add_many_end (ArrayList<Track> track_list) {
            bool should_change_track_state = _queue.tracks.size == 0;

            _queue.tracks.add_all (track_list);
            original_tracks.add_all (track_list);

            send_queue.begin ();
            player.queue_changed ();

            if (should_change_track_state) {
                player.start_current_track.begin (() => {
                    player.stop ();
                });
            }
        }
    }
}