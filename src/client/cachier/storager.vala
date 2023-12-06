/* storager.vala
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

namespace CassetteClient.Cachier {

    namespace Filenames {
        public const string COOKIES = "cassette.cookies";
        public const string LOG = "cassette.log";
        public const string DATABASE = "cassette.db";
        public const string IMAGES = "images";
        public const string TRACKS = "tracks";
        public const string OBJECTS = "objs";
    }


    public struct HumanitySize {
        public string size;
        public string unit;
    }


    public class Location : Object {
        /*
            Класс для удобного вывода месторасположения файла
        */

        public bool is_tmp { get; construct; }
        public string? path { get; construct; }

        public Location (bool is_tmp, string? path) {
            Object (is_tmp: is_tmp, path: path);
        }

        public Location.none () {
            Object (is_tmp: true, path: null);
        }

        public async void move_to_temp () {
            /*
                Переместить файл во временное хранилище, если он в постоянном
            */

            if (path != null && is_tmp == false) {
                threader.add (() => {
                    if (storager.settings.get_boolean ("can-cache")) {
                        storager.move (path, null, true);
                    } else {
                        storager.remove_file (path);
                    }

                    Idle.add (move_to_temp.callback);
                });

                yield;
            }
        }

        public async void move_to_perm () {
            /*
                Переместить файл в постоянное хранилище, если он во временном
            */

            if (path != null && is_tmp == true) {
                threader.add (() => {
                    storager.move (path, null, false);
                    Idle.add (move_to_perm.callback);
                });

                yield;
            }
        }
    }

    public class Storager : Object {
        /*
            Класс для работы с файлами клиента
        */

        public InfoDB db { get; private set; }
        public Settings settings { get; default = new Settings ("com.github.Rirusha.Cassette"); }

        public signal void moving_done ();

        string old_cache_path;

        string _cache_path;
        public string cache_path {
            get { return _cache_path; }
            set {
                if ("~/" in value) {
                    _cache_path = Path.build_filename (home_dir, value[2:]);
                } else {
                    _cache_path = value;
                }

                File cache_file = File.new_for_path (_cache_path);
                if (_cache_path != old_cache_path) {
                    if (cache_file.query_exists () == false) {
                        try {
                            cache_file.make_directory_with_parents ();
                        } catch (Error e) {
                            stderr.printf (@"Error: while making directory $(_cache_path)\n");
                        }
                    }

                    if (old_cache_path != null) {
                        move_dir (old_cache_path, _cache_path);
                        init_db ();
                    }

                    old_cache_path = _cache_path;
                }

                log_file_path = Path.build_filename (temp_dir, "cassette", "cassette.log");
                cookies_file_path = Path.build_filename (_cache_path, "cassette.cookies");
                db_file_path = Path.build_filename (cache_path, "cassette.db");
            }
        }

        string home_dir = Environment.get_home_dir ();
        string temp_dir;
        public string log_file_path { get; private set; }
        public string cookies_file_path { get; private set; }
        public string db_file_path { get; private set; }
        string temp_track_path;
        string temp_track_uri;

        public string temp_cache_path { get; private set; }

        public bool is_devel { get; construct; }
        public bool should_init_log_db { get; construct; }

        public Storager (bool is_devel, bool should_init_log_db = true) {
            Object (is_devel: is_devel, should_init_log_db: should_init_log_db);
        }

        construct {
            if (File.new_for_path ("/var/tmp").query_exists ()) {
                temp_dir = "/var/tmp";
            } else {
                temp_dir = Environment.get_tmp_dir ();
            }

            settings.bind ("cache-path", this, "cache-path", SettingsBindFlags.DEFAULT);
            //  temp_track_path = Path.build_filename (get_path ("cur", true), "track");
            temp_track_path = Path.build_filename (temp_dir, "track");
            temp_cache_path = Path.build_filename (temp_dir, "cassette");
            temp_track_uri = @"file://$temp_track_path";

            if (should_init_log_db) {
                init_log ();
                init_db ();
            }
        }

        void init_log () {
            /*
                Инициализировать файл логов. Удаляет файл лога при каждом выполнении
            */

            FileUtils.remove (log_file_path);

            if (is_devel) {
                new Logger (log_file_path, LogLevel.DEBUG_SOUP);
            } else {
                new Logger (log_file_path, LogLevel.WARNING);
            }

            Logger.info (_("Log created, loc - %s").printf (Logger.instance.log_path));
        }

        void init_db () {
            /*
                Инициализировать файл логов. Удаляет файл лога при каждом выполнении
            */

            db = new InfoDB (db_file_path);

            Logger.info (_("Database was initialized, loc - %s").printf (db.db_path));
        }

        public void move (string src, owned string? dst = null, bool to_tmp = false) {
            /*
                Перемещает файл
            */

            if (dst == null) {
                if (to_tmp) {
                    var b = src.split ("/cassette/");
                    dst = Path.build_filename (temp_cache_path, b[b.length - 1]);
                } else {
                    var b = src.split ("/cassette/");
                    dst = Path.build_filename (cache_path, b[b.length - 1]);
                }
            }

            var src_file = File.new_for_path (src);
            var dst_file = File.new_for_path (dst);

            try {
                src_file.move (dst_file, FileCopyFlags.OVERWRITE);
            } catch (Error e) { }
        }

        void move_dir (string src_dir, string dst_dir) {
            /*
                Перемещает директорию рекурсивно
            */

            try {
                FileEnumerator? enumerator = File.new_for_path (src_dir).enumerate_children (
                    "standard::*",
                    FileQueryInfoFlags.NONE,
                    null
                );

                if (enumerator != null) {
                    FileInfo? file_info = null;

                    while ((file_info = enumerator.next_file ()) != null) {
                        string file_name = file_info.get_name ();
                        string src_file_path = Path.build_filename (src_dir, file_name);
                        string dst_file_path = Path.build_filename (dst_dir, file_name);

                        if (file_info.get_file_type () == FileType.DIRECTORY) {
                            move_dir (src_file_path, dst_file_path);
                        } else {
                            File file = File.new_for_path (src_file_path);
                            file.move (File.new_for_path (dst_file_path), FileCopyFlags.OVERWRITE);
                        }
                    }
                }

                File.new_for_path (src_dir).delete ();

            } catch (Error e) {
                Logger.warning (_("Can't move directory. Message: %s").printf (e.message));
            }
        }

        public void remove_file (string file_path) {
            /*
                Удалить файл
            */

            FileUtils.remove (file_path);
        }

        void remove_dir (string dir) {
            /*
                Удаляет директорию рекурсивно
            */

            try {
                FileEnumerator? enumerator = File.new_for_path (dir).enumerate_children (
                    "standard::*",
                    FileQueryInfoFlags.NONE,
                    null
                );

                if (enumerator != null) {
                    FileInfo? file_info = null;

                    while ((file_info = enumerator.next_file ()) != null) {
                        string file_name = file_info.get_name ();
                        string file_path = Path.build_filename (dir, file_name);

                        if (file_info.get_file_type () == FileType.DIRECTORY) {
                            remove_dir (file_name);
                        } else {
                            File file = File.new_for_path (file_path);
                            file.delete ();
                        }
                    }
                }

                File file_dir = File.new_for_path (dir);
                file_dir.delete ();

            } catch (Error e) {
                Logger.warning (_("Can't move directory. Message: %s").printf (e.message));
            }

        }

        public void clear_user () {
            /*
                Удаляет пользовательские данные и переносить содержимое
                кэшей во временное 
            */

            move_dir (get_path (Filenames.OBJECTS, false), get_path (Filenames.OBJECTS, true));
            move_dir (get_path (Filenames.TRACKS, false), get_path (Filenames.TRACKS, true));
            move_dir (get_path (Filenames.IMAGES, false), get_path (Filenames.IMAGES, true));

            remove_dir (cache_path);

            moving_done ();
        }

        public async void delete_temp_cache () {
            /*
                Удаляет временные файлы
            */

            threader.add (() => {
                remove_dir (get_path (Filenames.OBJECTS, true));
                remove_dir (get_path (Filenames.TRACKS, true));
                remove_dir (get_path (Filenames.IMAGES, true));

                Idle.add (delete_temp_cache.callback);
            });

            yield;
        }

        string get_path (string filename, bool is_tmp) {
            /*
                Даёт путь и создает директории при необходимости
            */

            File path_file;
            if (is_tmp) {
                path_file = File.new_build_filename (temp_cache_path, filename);
            } else {
                path_file = File.new_build_filename (cache_path, filename);
            }

            if (path_file.query_exists () == false) {
                try {
                    path_file.make_directory_with_parents ();
                } catch (Error e) {
                    Logger.warning (_("Can't create %s").printf (_cache_path));
                }
            }
            return path_file.get_path ();
        }

        void dencode (ref uint8[] data) {
            /*
                "Перевернуть" данные (допустим закодировал)
            */

            for (int i = 0; i < data.length; i++) {
                data[i] = data[i] ^ 0xFF;
            }
        }

        string dencode_name (string name) {
            /*
                Закодировать имя в Base64
            */

            return Base64.encode (name.data).replace ("/", "=");
        }

        //////////////
        // Cookies  //
        //////////////

        public bool cookies_exists () {
            /*
                Проверка существования файла куки
            */

            var cookie_file = File.new_for_path (cookies_file_path);
            return cookie_file.query_exists ();
        }

        /////////////
        // Images  //
        /////////////

        File get_image_cache_file (string image_uri, bool is_tmp) {
            /*
                Получение файла кэширования изображения по его uri
            */

            string imagedir_path = get_path (Filenames.IMAGES, is_tmp);
            string image_name = dencode_name (image_uri);
            return File.new_build_filename (imagedir_path, image_name);
        }

        public Location image_cache_location (string image_uri) {
            File image_file;
            image_file = get_image_cache_file (image_uri, false);
            if (image_file.query_exists ()) {
                return new Location (false, image_file.get_path ());
            }
            image_file = get_image_cache_file (image_uri, true);
            if (image_file.query_exists ()) {
                return new Location (true, image_file.get_path ());
            }
            return new Location.none ();
        }

        public Gdk.Pixbuf? load_image (string image_uri) {
            Location image_location = image_cache_location (image_uri);
            if (image_location.path == null) {
                return null;
            }

            while (true) {
                try {
                    uint8[] idata;
                    FileUtils.get_data (image_location.path, out idata);
                    dencode (ref idata);

                    var stream = new MemoryInputStream.from_data (idata);
                    var pixbuf = new Gdk.Pixbuf.from_stream (stream);
                    stream.close ();
                    return pixbuf;
                } catch (Error e) {
                    GLib.Thread.usleep (1000000);
                    continue;
                }
            }
        }

        public void save_image (Gdk.Pixbuf image, string image_url, bool is_tmp = true) {
            File image_file = get_image_cache_file (image_url, is_tmp);
            try {
                uint8[] odata;
                image.save_to_buffer (out odata, "png");
                dencode (ref odata);

                FileUtils.set_data (image_file.get_path (), odata);
            } catch (Error e) {
                Logger.warning ((_("Can't save image %s").printf (image_url)));
            }
        }

        /////////////
        // Tracks  //
        /////////////

        File get_track_cache_file (string track_id, bool is_tmp) {
            string trackdir_path = get_path (Filenames.TRACKS, is_tmp);
            string track_name = dencode_name (track_id);
            return File.new_build_filename (trackdir_path, track_name);
        }

        public Location audio_cache_location (string track_id) {
            File track_file;
            track_file = get_track_cache_file (track_id, false);
            if (track_file.query_exists ()) {
                return new Location (false, track_file.get_path ());
            }
            track_file = get_track_cache_file (track_id, true);
            if (track_file.query_exists ()) {
                return new Location (true, track_file.get_path ());
            }
            return new Location.none ();
        }

        //  Расшифровывает трек, помещает его во временные файлы и даёт его uri
        public string? load_audio (string track_id) {
            Location track_location = audio_cache_location (track_id);
            if (track_location.path == null) {
                return null;
            }

            while (true) {
                try {
                    uint8[] idata;
                    FileUtils.get_data (track_location.path, out idata);
                    dencode (ref idata);

                    FileUtils.set_data (temp_track_path, idata);
                    return temp_track_uri;
                } catch (FileError e) {
                    GLib.Thread.usleep (100000);
                    continue;
                }
            }
        }

        public void clear_temp_track () {
            FileUtils.remove (temp_track_path);
        }

        public void save_audio (Bytes audio_bytes, string track_id, bool is_tmp = true) {
            File track_file = get_track_cache_file (track_id, is_tmp);
            try {
                uint8[] odata = audio_bytes.get_data ();
                dencode (ref odata);

                FileUtils.set_data (track_file.get_path (), odata);
            } catch (FileError e) {
                Logger.warning (_("Can't save audio %s").printf (track_id));
            }
        }

        ///////////////
        //  Objects  //
        ///////////////

        string build_id (Type build_type, string oid) {
            return build_type.name () + "/" + oid;
        }

        File get_object_cache_file (Type obj_type, string oid, bool is_tmp) {
            string objdir_path = get_path (Filenames.OBJECTS, is_tmp);
            string object_name = dencode_name (build_id (obj_type, oid));
            return File.new_build_filename (objdir_path, object_name);
        }

        public Location object_cache_location (Type obj_type, string oid) {
            File object_file;
            object_file = get_object_cache_file (obj_type, oid, false);
            if (object_file.query_exists ()) {
                return new Location (false, object_file.get_path ());
            }
            object_file = get_object_cache_file (obj_type, oid, true);
            if (object_file.query_exists ()) {
                return new Location (true, object_file.get_path ());
            }
            return new Location.none ();
        }

        public HasID? load_object (Type obj_type, string oid) {
            Location object_location = object_cache_location (obj_type, oid);
            if (object_location.path == null) {
                return null;
            }

            while (true) {
                try {
                    uint8[] idata;
                    FileUtils.get_data (object_location.path, out idata);
                    dencode (ref idata);

                    var jsoner = Jsoner.from_data (idata);
                    return (HasID) jsoner.deserialize_object (obj_type);
                } catch (Error e) {
                    GLib.Thread.usleep (1000000);
                    continue;
                }
            }
        }

        public void save_object (HasID yam_object, bool is_tmp) {
            File object_file = get_object_cache_file (yam_object.get_type (), yam_object.oid, is_tmp);
            try {
                uint8[] odata = Jsoner.serialize (yam_object).data;
                dencode (ref odata);

                FileUtils.set_data (object_file.get_path (), odata);
            } catch (Error e) {
                Logger.warning (_("Can't save object %s").printf (yam_object.get_type ().name ()));
            }
        }

        // 253.3M -> 253.3 Megabyte
        HumanitySize to_human (string input) {
            string size = input[0:input.length - 1];
            string unit;

            ulong size_long = (ulong) double.parse (size);

            switch (input[input.length - 1]) {
                case 'B':
                    unit = ngettext ("Byte", "Bytes", size_long);
                    break;
                case 'K':
                    unit = ngettext ("Kilobyte", "Kilobytes", size_long);
                    break;
                case 'M':
                    unit = ngettext ("Megabyte", "Megabytes", size_long);
                    break;
                case 'G':
                    unit = ngettext ("Gigabyte", "Gigabytes", size_long);
                    break;
                case 'T':
                    unit = ngettext ("Terabyte", "Terabytes", size_long);
                    break;
                default:
                    assert_not_reached ();
            }

            return {size, unit};
        }

        public async HumanitySize get_temp_size () {
            string size = "";

            threader.add (() => {
                try {
                    Process.spawn_command_line_sync ("du -sh %s --exclude=\"*.log\"".printf (storager.temp_cache_path), out size);

                    Regex regex = null;
                    regex = new Regex ("^[\\d.,]+[A-Z]", RegexCompileFlags.OPTIMIZE, RegexMatchFlags.NOTEMPTY);

                    MatchInfo match_info;
                    if (regex.match (size, 0, out match_info)) {
                        size = match_info.fetch (0);
                    } else {
                        size = "";
                    }

                } catch (Error e) {
                    Logger.warning (_("Error while getting temporary dir size. Message %s").printf (e.message));
                }

                Idle.add (get_temp_size.callback);
            });

            yield;

            if (size != "") {
                return to_human (size);
            } else {
                return to_human ("0B");
            }
        }

        public async HumanitySize get_perm_size () {
            string size = "";

            threader.add (() => {
                try {
                    Process.spawn_command_line_sync ("du -sh %s --exclude=\"*.db\" --exclude=\"*.cookies\"".printf (storager.cache_path), out size);

                    Regex regex = null;
                    regex = new Regex ("^[\\d.,]+[A-Z]", RegexCompileFlags.OPTIMIZE, RegexMatchFlags.NOTEMPTY);

                    MatchInfo match_info;
                    if (regex.match (size, 0, out match_info)) {
                        size = match_info.fetch (0);
                    } else {
                        size = "";
                    }

                } catch (Error e) {
                    Logger.warning (_("Error while getting permanent dir size. Message %s").printf (e.message));
                }

                Idle.add (get_perm_size.callback);
            });

            yield;

            if (size != "") {
                return to_human (size);
            } else {
                return to_human ("0B");
            }
        }
    }
}
