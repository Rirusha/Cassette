/*
 * Copyright (C) 2024 Vladimir Romanov
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
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

internal class Tape.SyncData : Deser.DataObject {

    public class LikedAlbums : Deser.DataObject {

        public class Info : Deser.DataObject {

            public class Checksum : Deser.DataObject {
                public string album_ids_mur_mur_2 { get; set; }
            }

            public int64 revision { get; set; }

            public Checksum checksum { get; set; }
        }

        public class Values : Deser.DataObject {

            public class Album : Deser.DataObject {
                public int64 album_id { get; set; }
                public string timestamp { get; set; }
            }

            public Album[] liked { get; set; }
        }

        public Info info { get; set; }

        public Values values { get; set; }
    }

    public class LikedArtists : Deser.DataObject {

        public class Info : Deser.DataObject {

            public class Checksum : Deser.DataObject {
                public string liked_artist_ids_mur_mur_2 { get; set; }
                public string disliked_artist_ids_mur_mur_2 { get; set; }
            }

            public int64 revision { get; set; }

            public Checksum checksum { get; set; }
        }

        public class Values : Deser.DataObject {

            public class Artist : Deser.DataObject {
                public int64 artist_id { get; set; }
                public string timestamp { get; set; }
            }

            public Artist[] liked { get; set; }

            public Artist[] disliked { get; set; }
        }

        public Info info { get; set; }

        public Values values { get; set; }
    }

    public class LikedClips : Deser.DataObject {

        public class Info : Deser.DataObject {

            public class Checksum : Deser.DataObject {
                public string liked_clip_ids_mur_mur_2 { get; set; }
                public string disliked_clip_ids_mur_mur_2 { get; set; }
            }

            public int64 revision { get; set; }

            public Checksum checksum { get; set; }
        }

        public class Values : Deser.DataObject {

            public class Clip : Deser.DataObject {
                public int64 clip_id { get; set; }
                public string timestamp { get; set; }
            }

            public Clip[] liked { get; set; }

            public Clip[] disliked { get; set; }
        }

        public Info info { get; set; }

        public Values values { get; set; }
    }

    public class LikedPlaylists : Deser.DataObject {

        public class Values : Deser.DataObject {

            public class Playlist : Deser.DataObject {

                public class CompositeData : Deser.DataObject {
                    public int64 uid { get; set; }
                    public int64 kind { get; set; }
                    public string timestamp { get; set; }
                }

                public class Info : Deser.DataObject {
                    public int64 revision { get; set; }
                    public int64 snapshot { get; set; }
                }

                public CompositeData composite_data { get; set; }

                public Info info { get; set; }
            }

            public Playlist[] liked { get; set; }
        }

        public Values values { get; set; }
    }

    public class LikedTracks : Deser.DataObject {

        public class Info : Deser.DataObject {

            public class Checksum : Deser.DataObject {
                public string liked_track_ids_mur_mur_2 { get; set; }
                public string disliked_track_ids_mur_mur_2 { get; set; }
            }

            public int64 revision { get; set; }

            public Checksum checksum { get; set; }
        }

        public class Values : Deser.DataObject {

            public class Track : Deser.DataObject {

                public string track_id { get; set; }

                public string? album_id { get; set; }

                public string timestamp { get; set; }

                public override Deser.ValueCodec get_property_codec (GLib.ParamSpec property) throws Deser.Error {
                    switch (property.name) {
                        case "track-id":
                        case "album-id":
                            return new Deser.CodecAuto (property.value_type);
                        default:
                            return base.get_property_codec (property);
                    }
                }
            }

            public Track[] liked { get; set; }

            public Track[] disliked { get; set; }
        }

        public Info info { get; set; }

        public Values values { get; set; }
    }

    public class LikedWaves : Deser.DataObject {

        public class Info : Deser.DataObject {

            public class Checksum : Deser.DataObject {
                public string liked_waves_mur_mur_2 { get; set; }
            }

            public int64 revision { get; set; }

            public Checksum checksum { get; set; }
        }

        public class Values : Deser.DataObject {

            public class Wave : Deser.DataObject {
            }

            public Wave[] liked { get; set; }
        }

        public Info info { get; set; }

        public Values values { get; set; }
    }

    public LikedAlbums liked_albums { get; set; }

    public LikedArtists liked_artists { get; set; }

    public LikedClips liked_clips { get; set; }

    public LikedPlaylists liked_playlists { get; set; }

    public LikedTracks liked_tracks { get; set; }

    public LikedWaves liked_waves { get; set; }
}
