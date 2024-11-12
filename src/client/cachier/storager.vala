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

namespace Cassette.Client.Cachier {

    namespace Filenames {
        public const string ROOT_DIR_NAME = "cassette";
        public const string COOKIES = "cassette.cookies";
        public const string LOG = "cassette.log";
        public const string DATABASE = "cassette.db";
        public const string IMAGES = "images";
        public const string AUDIOS = "audios";
        public const string OBJECTS = "objs";
    }


    public struct HumanitySize {
        public string size;
        public string unit;
    }


    public class Location : Object {
        /**
            Класс для удобного вывода месторасположения файла
        */

        public bool is_tmp { get; construct; }
        public File? file { get; construct; }

        public Location (bool is_tmp, File? file) {
            Object (is_tmp: is_tmp, file: file);
        }

        public Location.none () {
            Object (is_tmp: true, file: null);
        }

        public void move_to_temp () {
            /**
                Переместить файл во временное хранилище, если он в постоянном
            */

            if (file != null && is_tmp == false) {
                if (settings.get_boolean ("can-cache")) {
                    storager.move_file_to (file, true);
                } else {
                    storager.remove_file (file);
                }
            }
        }

        public async void move_to_temp_async () {
            /**
                Переместить файл во временное хранилище, если он в постоянном
            */

            if (file != null && is_tmp == false) {
                threader.add (() => {
                    if (settings.get_boolean ("can-cache")) {
                        storager.move_file_to (file, true);
                    } else {
                        storager.remove_file (file);
                    }

                    Idle.add (move_to_temp_async.callback);
                });

                yield;
            }
        }

        public void move_to_perm () {
            /**
                Переместить файл в постоянное хранилище, если он во временном
            */

            if (file != null && is_tmp == true) {
                storager.move_file_to (file, false);
            }
        }

        public async void move_to_perm_async () {
            /**
                Переместить файл в постоянное хранилище, если он во временном
            */

            if (file != null && is_tmp == true) {
                threader.add (() => {
                    storager.move_file_to (file, false);
                    Idle.add (move_to_perm_async.callback);
                });

                yield;
            }
        }
    }

    public class Storager : Object {
        /**
           A class for working with client files
        */

        InfoDB? _db = null;
        public InfoDB db {
            get {
                if (_db == null) {
                    _db = new InfoDB (db_file.peek_path ());

                    Logger.info (_("Database was initialized, loc - %s").printf (db.db_path));
                }

                return _db;
            }
        }

        // Permanent root dir
        File _data_dir_file;
        public File data_dir_file {
            get {
                lock (_data_dir_file) {
                    create_dir_if_not_existing (_data_dir_file);
                }

                return _data_dir_file;
            }
        }

        // Permanent images dir
        File _data_images_dir_file;
        public File data_images_dir_file {
            get {
                lock (_data_images_dir_file) {
                    create_dir_if_not_existing (_data_images_dir_file);
                }

                return _data_images_dir_file;
            }
        }

        // Permanent audios dir
        File _data_audios_dir_file;
        public File data_audios_dir_file {
            get {
                lock (_data_audios_dir_file) {
                    create_dir_if_not_existing (_data_audios_dir_file);
                }

                return _data_audios_dir_file;
            }
        }

        // Permanent objects dir
        File _data_objects_dir_file;
        public File data_objects_dir_file {
            get {
                lock (_data_objects_dir_file) {
                    create_dir_if_not_existing (_data_objects_dir_file);
                }

                return _data_objects_dir_file;
            }
        }

        // Temporary root dir
        File _cache_dir_file;
        public File cache_dir_file {
            get {
                lock (_cache_dir_file) {
                    create_dir_if_not_existing (_cache_dir_file);
                }

                return _cache_dir_file;
            }
        }

        // Temporary images dir
        File _cache_images_dir_file;
        public File cache_images_dir_file {
            get {
                lock (_cache_images_dir_file) {
                    create_dir_if_not_existing (_cache_images_dir_file);
                }

                return _cache_images_dir_file;
            }
        }

        // Temporary audios dir
        File _cache_audios_dir_file;
        public File cache_audios_dir_file {
            get {
                lock (_cache_audios_dir_file) {
                    create_dir_if_not_existing (_cache_audios_dir_file);
                }

                return _cache_audios_dir_file;
            }
        }

        // Temporary objects dir
        File _cache_objects_dir_file;
        public File cache_objects_dir_file {
            get {
                lock (_cache_objects_dir_file) {
                    create_dir_if_not_existing (_cache_objects_dir_file);
                }

                return _cache_objects_dir_file;
            }
        }

        File _log_file;
        public File log_file {
            get {
                file_exists (_log_file);

                return _log_file;
            }
        }

        File _db_file;
        public File db_file {
            get {
                file_exists (_db_file);

                return _db_file;
            }
        }

        File _cookies_file;
        public File cookies_file {
            get {
                file_exists (_cookies_file);

                return _cookies_file;
            }
        }

        string temp_audio_path;
        string temp_audio_uri;

        public Storager () {
            Object ();
        }

        construct {
            _data_dir_file = File.new_build_filename (Environment.get_user_data_dir (), Filenames.ROOT_DIR_NAME);

            _db_file = File.new_build_filename (data_dir_file.peek_path (), Filenames.DATABASE);
            _cookies_file = File.new_build_filename (data_dir_file.peek_path (), Filenames.COOKIES);

            _data_images_dir_file = File.new_build_filename (data_dir_file.peek_path (), Filenames.IMAGES);
            _data_audios_dir_file = File.new_build_filename (data_dir_file.peek_path (), Filenames.AUDIOS);
            _data_objects_dir_file = File.new_build_filename (data_dir_file.peek_path (), Filenames.OBJECTS);


            _cache_dir_file = File.new_build_filename (Environment.get_user_cache_dir (), Filenames.ROOT_DIR_NAME);

            _log_file = File.new_build_filename (cache_dir_file.peek_path (), Filenames.LOG);
            Logger.log_file = _log_file;

            _cache_images_dir_file = File.new_build_filename (cache_dir_file.peek_path (), Filenames.IMAGES);
            _cache_audios_dir_file = File.new_build_filename (cache_dir_file.peek_path (), Filenames.AUDIOS);
            _cache_objects_dir_file = File.new_build_filename (cache_dir_file.peek_path (), Filenames.OBJECTS);


            temp_audio_path = Path.build_filename (cache_dir_file.peek_path (), ".track");
            temp_audio_uri = @"file://$temp_audio_path";

            Logger.debug ("Storager initialized");
        }

        static bool file_exists (File target_file) {
            if (target_file.query_exists ()) {
                return true;

            } else {
                Logger.info ("Location '%s' was not found.".printf (target_file.peek_path ()));

                return false;
            }
        }

        static void create_dir_if_not_existing (File target_file) {
            if (!file_exists (target_file)) {
                try {
                    target_file.make_directory_with_parents ();

                    Logger.info ("Directory '%s' created".printf (target_file.peek_path ()));
                } catch (Error e) {
                    Logger.error ("Error while creating directory '%s'. Error message: %s".printf (
                        target_file.peek_path (),
                        e.message
                    ));
                }
            }
        }

        public void move_to (string src_path, bool is_tmp) {
             move_file_to (
                File.new_for_path (src_path),
                is_tmp
            );
        }

        public void move_file_to (File src_file, bool is_tmp) {
            var b = src_file.peek_path ().split ("/cassette/");
            File dst_file = File.new_build_filename (
                is_tmp? cache_dir_file.peek_path () : data_dir_file.peek_path (),
                b[b.length - 1]
            );

            move_file (
                src_file,
                dst_file
            );
        }

        void move_file (File src_file, File dst_file) {
            /**
                Перемещает файл
            */

            try {
                src_file.move (dst_file, FileCopyFlags.OVERWRITE);
            } catch (Error e) {
                Logger.warning ("Can't move file '%s' to '%s'. Error message: %s".printf (
                    src_file.peek_path (),
                    dst_file.peek_path (),
                    e.message
                ));
            }
        }

        void move_file_dir (File src_dir_file, File dst_dir_file) {
            /**
                Перемещает директорию рекурсивно
            */

            try {
                FileEnumerator? enumerator = src_dir_file.enumerate_children (
                    "standard::*",
                    FileQueryInfoFlags.NONE,
                    null
                );

                if (enumerator != null) {
                    FileInfo? file_info = null;

                    while ((file_info = enumerator.next_file ()) != null) {
                        string file_name = file_info.get_name ();

                        File src_file = File.new_build_filename (src_dir_file.peek_path (), file_name);
                        File dst_file = File.new_build_filename (dst_dir_file.peek_path (), file_name);

                        if (file_info.get_file_type () == FileType.DIRECTORY) {
                            move_file_dir (src_file, dst_file);
                        } else if (file_info.get_file_type () == FileType.REGULAR) {
                            move_file (src_file, dst_file);
                        } else {
                            src_file.trash ();
                            Logger.warning (
                                "In cache folder found suspicious file '%s'. It moved to trash.".printf (file_name)
                            );
                        }
                    }
                }

                src_dir_file.delete ();

            } catch (Error e) {
                Logger.warning ("Can't move directory '%s' to '%s'. Error message: %s".printf (
                    src_dir_file.peek_path (),
                    dst_dir_file.peek_path (),
                    e.message
                ));
            }
        }

        public void remove_file (File target_file) {
            /**
                Удалить файл
            */

            try {
                target_file.delete ();

            } catch (Error e) {
                Logger.warning ("Can't delete file '%s'. Error message: %s".printf (
                    target_file.peek_path (),
                    e.message
                ));
            }
        }

        public void remove (string file_path) {
            /**
                Удалить файл используя путь
            */

            remove_file (File.new_for_path (file_path));
        }

        void remove_dir_file (File dir_file) {
            /**
                Удаляет директорию рекурсивно
            */

            try {
                FileEnumerator? enumerator = dir_file.enumerate_children (
                    "standard::*",
                    FileQueryInfoFlags.NONE,
                    null
                );

                if (enumerator != null) {
                    FileInfo? file_info = null;

                    while ((file_info = enumerator.next_file ()) != null) {
                        string file_name = file_info.get_name ();

                        File file = File.new_build_filename (dir_file.peek_path (), file_name);

                        if (file_info.get_file_type () == FileType.DIRECTORY) {
                            remove_dir_file (file);
                        } else if (file_info.get_file_type () == FileType.REGULAR) {
                            remove_file (file);
                        } else {
                            file.trash ();
                            Logger.warning (
                                "In cache folder found suspicious file '%s'. It moved to trash.".printf (file_name)
                            );
                        }
                    }
                }

                dir_file.delete ();

            } catch (Error e) {
                Logger.warning ("Can't remove directory '%s'. Error message: %s".printf (
                    dir_file.peek_path (),
                    e.message
                ));
            }
        }

        /**
         * Remove user data and move content to cache
         *
         * @param keep_content  remove content or keep
         * @param keep_settings remove cookies and other or
         */
        public async void clear_user (bool keep_content, bool keep_datadir) {
            threader.add (() => {
                if (keep_content) {
                    move_file_dir (data_images_dir_file, cache_images_dir_file);
                    move_file_dir (data_objects_dir_file, cache_objects_dir_file);
                    move_file_dir (data_audios_dir_file, cache_audios_dir_file);
                }

                _db = null;
                remove_file (db_file);

                if (!keep_datadir) {
                    remove_dir_file (data_dir_file);
                }

                Idle.add (clear_user.callback);
            });

            yield;
        }

        public async void delete_temp_cache () {
            /**
                Удаляет временные файлы
            */

            threader.add (() => {
                remove_dir_file (cache_dir_file);

                Idle.add (delete_temp_cache.callback);
            });

            yield;
        }

        /**
         * Simple encoding to protect DRM content from direct access.
         * Please do not publish an uncoded version on the Internet and do
         * not distribute a workaround (albeit a simple one).
         * This may cause the developer to have problems with Yandex.
         */
        void simple_dencode (ref uint8[] data) {
            for (int i = 0; i < data.length; i++) {
                data[i] = data[i] ^ 0xFF;
            }
        }

        string replace_many (string in_str, char[] targets, char replacement) {
            var builder = new StringBuilder ();

            for (int i = 0; i < in_str.length; i++) {
                if (in_str[i] in targets) {
                    builder.append_c (replacement);
                } else {
                    builder.append_c (in_str[i]);
                }
            }

            var o = builder.free_and_steal ();

            return o;
        }

        string encode_name (string name) {
            /**
                Закодировать имя в Base64
            */

            return replace_many (Base64.encode (name.data), {'/', '+', '='}, '-');
        }

        /////////////
        // Images  //
        /////////////

        File get_image_cache_file (string image_uri, bool is_tmp) {
            /**
                Получение файла кэширования изображения по его uri
            */

            return File.new_build_filename (
                is_tmp? cache_images_dir_file.peek_path () : data_images_dir_file.peek_path (),
                encode_name (image_uri)
            );
        }

        public Location image_cache_location (string image_uri) {
            File image_file;
            image_file = get_image_cache_file (image_uri, false);
            if (image_file.query_exists ()) {
                return new Location (false, image_file);
            }
            image_file = get_image_cache_file (image_uri, true);
            if (image_file.query_exists ()) {
                return new Location (true, image_file);
            }
            return new Location.none ();
        }

        public Gdk.Pixbuf? load_image (string image_uri) {
            Location image_location = image_cache_location (image_uri);
            if (image_location.file == null) {
                return null;
            }

            while (true) {
                try {
                    uint8[] idata;
                    image_location.file.load_contents (null, out idata, null);
                    simple_dencode (ref idata);

                    var stream = new MemoryInputStream.from_data (idata);
                    var pixbuf = new Gdk.Pixbuf.from_stream (stream);
                    stream.close ();
                    return pixbuf;

                } catch (Error e) {
                    Logger.warning ("Can't load image '%s'. Error message: %s".printf (
                        image_location.file.peek_path (),
                        e.message
                    ));
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
                simple_dencode (ref odata);

                FileUtils.set_data (image_file.peek_path (), odata);

            } catch (Error e) {
                Logger.warning (("Can't save image %s".printf (image_url)));
            }
        }

        /////////////
        // Audios  //
        /////////////

        File get_audio_cache_file (string track_id, bool is_tmp) {
            /**
                Получение файла аудио по id трека
            */

            return File.new_build_filename (
                is_tmp? cache_audios_dir_file.peek_path () : data_audios_dir_file.peek_path (),
                encode_name (track_id)
            );
        }

        public Location audio_cache_location (string track_id) {
            File track_file;
            track_file = get_audio_cache_file (track_id, false);
            if (track_file.query_exists ()) {
                return new Location (false, track_file);
            }
            track_file = get_audio_cache_file (track_id, true);
            if (track_file.query_exists ()) {
                return new Location (true, track_file);
            }
            return new Location.none ();
        }

        //  Расшифровывает трек, помещает его во временные файлы и даёт его uri
        public string? load_audio (string track_id) {
            Location audio_location = audio_cache_location (track_id);
            if (audio_location.file == null) {
                return null;
            }

            while (true) {
                try {
                    uint8[] idata;
                    audio_location.file.load_contents (null, out idata, null);
                    simple_dencode (ref idata);

                    FileUtils.set_data (temp_audio_path, idata);
                    return temp_audio_uri;

                } catch (Error e) {
                    Logger.warning ("Can't load audio '%s'. Error message: %s".printf (
                        audio_location.file.peek_path (),
                        e.message
                    ));
                    GLib.Thread.usleep (100000);
                    continue;
                }
            }
        }

        public void clear_temp_track () {
            FileUtils.remove (temp_audio_path);
        }

        public void save_audio (Bytes audio_bytes, string track_id, bool is_tmp) {
            File audio_file = get_audio_cache_file (track_id, is_tmp);
            try {
                uint8[] odata = audio_bytes.get_data ();
                simple_dencode (ref odata);

                FileUtils.set_data (audio_file.peek_path (), odata);

            } catch (FileError e) {
                Logger.warning ("Can't save audio '%s'. Error message: %s".printf (
                    audio_file.peek_path (),
                    e.message
                ));
            }
        }

        ///////////////
        //  Objects  //
        ///////////////

        string build_id (Type build_type, string oid) {
            return build_type.name () + "-" + oid;
        }

        public HasTrackList[] get_saved_objects () {
            // Открыть папку с сохраненными оъектами, десериализовать их. Получить только альбомы и плейлисты.

            var obj_arr = new Array<HasTrackList> ();

            try {
                FileEnumerator? enumerator = data_objects_dir_file.enumerate_children (
                    "standard::*",
                    FileQueryInfoFlags.NONE,
                    null
                );

                if (enumerator != null) {
                    FileInfo? file_info = null;

                    string filename;
                    File file;
                    string decoded_name;
                    Type obj_type;

                    while ((file_info = enumerator.next_file ()) != null) {
                        filename = file_info.get_name ();
                        file = File.new_build_filename (data_objects_dir_file.peek_path (), filename);

                        decoded_name = (string) (Base64.decode (filename));

                        if ((typeof (YaMAPI.Playlist)).name () in decoded_name) {
                            obj_type = typeof (YaMAPI.Playlist);
                        } else if ((typeof (YaMAPI.Album)).name () in decoded_name) {
                            obj_type = typeof (YaMAPI.Album);
                        } else {
                            continue;
                        }

                        uint8[] idata;
                        file.load_contents (null, out idata, null);
                        simple_dencode (ref idata);

                        var jsoner = Jsoner.from_data (idata);
                        var des_obj = (HasTrackList) jsoner.deserialize_object (obj_type);

                        obj_arr.append_val (des_obj);
                    }
                }

            } catch (Error e) {
                Logger.warning ("Can't find '%s'. Error message: %s".printf (
                    data_objects_dir_file.peek_path (),
                    e.message
                ));
            }

            return obj_arr.data;
        }

        File get_object_cache_file (Type obj_type, string oid, bool is_tmp) {
            /**
                Получение файла файлла аудио по его типу и id
            */

            return File.new_build_filename (
                is_tmp? cache_objects_dir_file.peek_path () : data_objects_dir_file.peek_path (),
                encode_name (build_id (obj_type, oid))
            );
        }

        public Location object_cache_location (Type obj_type, string oid) {
            File object_file;
            object_file = get_object_cache_file (obj_type, oid, false);
            if (object_file.query_exists ()) {
                return new Location (false, object_file);
            }
            object_file = get_object_cache_file (obj_type, oid, true);
            if (object_file.query_exists ()) {
                return new Location (true, object_file);
            }
            return new Location.none ();
        }

        public HasID? load_object (Type obj_type, string oid) {
            Location object_location = object_cache_location (obj_type, oid);
            if (object_location.file == null) {
                return null;
            }

            while (true) {
                try {
                    uint8[] idata;
                    object_location.file.load_contents (null, out idata, null);
                    simple_dencode (ref idata);

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
                simple_dencode (ref odata);

                FileUtils.set_data (object_file.peek_path (), odata);
            } catch (Error e) {
                Logger.warning (_("Can't save object %s").printf (yam_object.get_type ().name ()));
            }
        }

        /////////////
        //  Other  //
        /////////////

        // 253.3M -> 253.3 Megabytes
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
                    Process.spawn_command_line_sync ("du -sh %s --exclude=\"*.log\"".printf (
                        storager.cache_dir_file.peek_path ()
                    ), out size);

                    Regex regex = null;
                    regex = new Regex ("^[\\d.,]+[A-Z]", RegexCompileFlags.OPTIMIZE, RegexMatchFlags.NOTEMPTY);

                    MatchInfo match_info;
                    if (regex.match (size, 0, out match_info)) {
                        size = match_info.fetch (0);
                    } else {
                        size = "";
                    }

                } catch (Error e) {
                    Logger.warning (_("Error while getting cache directory size. Message %s").printf (e.message));
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
                    Process.spawn_command_line_sync ("du -sh %s --exclude=\"*.db\" --exclude=\"*.cookies\"".printf (
                        storager.data_dir_file.peek_path ()
                    ), out size);

                    Regex regex = null;
                    regex = new Regex ("^[\\d.,]+[A-Z]", RegexCompileFlags.OPTIMIZE, RegexMatchFlags.NOTEMPTY);

                    MatchInfo match_info;
                    if (regex.match (size, 0, out match_info)) {
                        size = match_info.fetch (0);
                    } else {
                        size = "";
                    }

                } catch (Error e) {
                    Logger.warning (_("Error while getting permanent directory size. Message %s").printf (e.message));
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
