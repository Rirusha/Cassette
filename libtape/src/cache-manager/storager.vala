/*
 * Copyright (C) 2024-2026 Vladimir Romanov <rirusha@altlinux.org>
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

/**
 * A class for working with client files
 */
public class Tape.Storager : Object {

    InfoDB? _db = null;
    public InfoDB db {
        get {
            if (_db == null) {
                _db = new InfoDB (db_file.peek_path ());

                info ("Database was initialized, loc - %s", db.db_path);
            }

            return _db;
        }
    }

    File _root_datadir_file;
    public File datadir_file {
        get {
            if (_root_datadir_file == null) {
                _root_datadir_file = File.new_build_filename (Environment.get_user_data_dir (), Filenames.data_root ());
            }
            create_dir_if_not_existing (_root_datadir_file);

            return _root_datadir_file;
        }
    }

    File _images_datadir_file;
    public File images_datadir_file {
        get {
            if (_images_datadir_file == null) {
                _images_datadir_file = File.new_build_filename (datadir_file.peek_path (), Filenames.IMAGES);
            }
            create_dir_if_not_existing (_images_datadir_file);

            return _images_datadir_file;
        }
    }

    File _audios_datadir_file;
    public File audios_datadir_file {
        get {
            if (_audios_datadir_file == null) {
                _audios_datadir_file = File.new_build_filename (datadir_file.peek_path (), Filenames.AUDIOS);
            }
            create_dir_if_not_existing (_audios_datadir_file);

            return _audios_datadir_file;
        }
    }

    File _objects_datadir_file;
    public File objects_datadir_file {
        get {
            if (_objects_datadir_file == null) {
                _objects_datadir_file = File.new_build_filename (datadir_file.peek_path (), Filenames.OBJECTS);
            }
            create_dir_if_not_existing (_objects_datadir_file);

            return _objects_datadir_file;
        }
    }

    File _cachedir_file;
    public File cachedir_file {
        get {
            if (_cachedir_file == null) {
                _cachedir_file = File.new_build_filename (Environment.get_user_cache_dir (), Filenames.data_root ());
            }
            create_dir_if_not_existing (_cachedir_file);

            return _cachedir_file;
        }
    }

    // Temporary images dir
    File _images_cachedir_file;
    public File images_cachedir_file {
        get {
            if (_images_cachedir_file == null) {
                _images_cachedir_file = File.new_build_filename (cachedir_file.peek_path (), Filenames.IMAGES);
            }
            create_dir_if_not_existing (_images_cachedir_file);

            return _images_cachedir_file;
        }
    }

    // Temporary audios dir
    File _audios_cachedir_file;
    public File audios_cachedir_file {
        get {
            if (_audios_cachedir_file == null) {
                _audios_cachedir_file = File.new_build_filename (cachedir_file.peek_path (), Filenames.AUDIOS);
            }
            create_dir_if_not_existing (_audios_cachedir_file);

            return _audios_cachedir_file;
        }
    }

    // Temporary objects dir
    File _objects_cachedir_file;
    public File objects_cachedir_file {
        get {
            if (_objects_cachedir_file == null) {
                _objects_cachedir_file = File.new_build_filename (cachedir_file.peek_path (), Filenames.OBJECTS);
            }
            create_dir_if_not_existing (_objects_cachedir_file);

            return _objects_cachedir_file;
        }
    }

    File _log_file;
    public File log_file {
        get {
            if (_log_file == null) {
                _log_file = File.new_build_filename (cachedir_file.peek_path (), Filenames.LOG);
            }

            return _log_file;
        }
    }

    File _db_file;
    public File db_file {
        get {
            if (_db_file == null) {
                _db_file = File.new_build_filename (datadir_file.peek_path (), Filenames.DATABASE);
            }

            return _db_file;
        }
    }

    File _cookies_file;
    public File cookies_file {
        get {
            if (_cookies_file == null) {
                _cookies_file = File.new_build_filename (datadir_file.peek_path (), Filenames.COOKIES);
            }

            return _cookies_file;
        }
    }

    /**
     * Remove file from datadir. Move it to cache dir or delete
     * if ``keep_on_disk`` is false
     *
     * @param loc           file location
     * @param keep_on_disk  keep file on disk or remove
     */
    public async void move_loc_to_temp (Location loc, bool keep_on_disk = true) {
        if (loc.file != null && loc.is_tmp == false) {
            if (keep_on_disk) {
                yield move_file_to (loc.file, true);
            } else {
                yield remove_file (loc.file);
            }
        }
    }

    /**
     * Move file from cache dir to datadir
     *
     * @param loc           file location
     */
    public async void move_loc_to_perm (Location loc) {
        yield move_file_to (loc.file, false);
    }

    static bool file_exists (File target_file) {
        if (target_file.query_exists ()) {
            return true;

        } else {
            info ("Location '%s' was not found.", target_file.peek_path ());
            return false;
        }
    }

    static void create_dir_if_not_existing (File target_file) {
        if (!file_exists (target_file)) {
            try {
                target_file.make_directory_with_parents ();

                info ("Directory '%s' created", target_file.peek_path ());

            } catch (Error e) {
                error (
                    "Error while creating directory '%s'. Error message: %s",
                    target_file.peek_path (),
                    e.message
                );
            }
        }
    }

    public async void move_to (string src_path, bool is_tmp) {
        yield move_file_to (
            File.new_for_path (src_path),
            is_tmp
        );
    }

    public async void move_file_to (File src_file, bool is_tmp) {
        var b = src_file.peek_path ().split ("/tape/");

        File dst_file = File.new_build_filename (
            is_tmp ? cachedir_file.peek_path () : datadir_file.peek_path (),
            b[b.length - 1]
        );

        yield move_file (src_file, dst_file);
    }

    async void move_file (File src_file, File dst_file) {
        /**
            Перемещает файл
         */

        try {
            yield src_file.move_async (
                dst_file,
                FileCopyFlags.OVERWRITE,
                Priority.DEFAULT,
                null,
                null
            );

        } catch (Error e) {
            warning (
                "Can't move file '%s' to '%s'. Error message: %s",
                src_file.peek_path (),
                dst_file.peek_path (),
                e.message
            );
        }
    }

    async void move_file_dir (File src_dir_file, File dst_dir_file) {
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
                        yield move_file_dir (src_file, dst_file);

                    } else if (file_info.get_file_type () == FileType.REGULAR) {
                        yield move_file (src_file, dst_file);

                    } else {
                        yield src_file.trash_async ();

                        warning ("In cache folder found suspicious file '%s'. It moved to trash.", file_name);
                    }
                }
            }
            yield src_dir_file.delete_async ();

        } catch (Error e) {
            warning (
                "Can't move directory '%s' to '%s'. Error message: %s",
                src_dir_file.peek_path (),
                dst_dir_file.peek_path (),
                e.message
            );
        }
    }

    /**
     * Delete file with error handle.
     */
    public async static void remove_file (File target_file) {
        try {
            yield target_file.delete_async ();

        } catch (Error e) {
            warning ("Can't delete file '%s'. Error message: %s",
                target_file.peek_path (),
                e.message
            );
        }
    }

    public async static void remove_async (string file_path) {
        yield remove_file (File.new_for_path (file_path));
    }

    internal async void remove_dir_file (File dir_file) {

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
                        yield remove_dir_file (file);

                    } else if (file_info.get_file_type () == FileType.REGULAR) {
                        yield remove_file (file);

                    } else {
                        yield file.trash_async ();

                        warning ("In cache folder found suspicious file '%s'. It moved to trash.", file_name);
                    }
                }
            }
            dir_file.delete ();

        } catch (Error e) {
            warning (
                "Can't remove directory '%s'. Error message: %s",
                dir_file.peek_path (),
                e.message
            );
        }
    }

    internal void save_token (string token) {
        uint8[] token_data = token.data.copy ();
        simple_dencode (ref token_data);

        var ar = new string[token_data.length];
        for (int i = 0; i < token_data.length; i++) {
            ar[i] = token_data[i].to_string ();
        }

        db.set_additional_data ("token", string.joinv ("/", ar));
    }

    internal string? load_token () {
        var token_datas = db.get_additional_data ("token");

        if (token_datas == null) {
            return null;
        }

        var token_datas_splitted = token_datas.split ("/");
        var token_data = new uint8[token_datas_splitted.length];
        for (int i = 0; i < token_data.length; i++) {
            token_data[i] = (uint8) uint.parse (token_datas_splitted[i]);
        }

        simple_dencode (ref token_data);
        return (string) token_data;
    }

    /**
     * Remove user data and move content to cache
     *
     * @param keep_content  remove content or keep
     * @param keep_settings remove cookies and other or
     */
    public async void clear_user_data (bool keep_content, bool keep_datadir) {
        if (keep_content) {
            yield move_file_dir (images_datadir_file, images_cachedir_file);
            yield move_file_dir (objects_datadir_file, objects_cachedir_file);
            yield move_file_dir (audios_datadir_file, audios_cachedir_file);
        }

        _db = null;
        yield remove_file (db_file);

        if (!keep_datadir) {
            yield remove_dir_file (datadir_file);
        }
    }

    /**
     * Simple encoding to protect DRM content from direct access.
     * Please do not publish an uncoded version on the Internet and do
     * not distribute a workaround (albeit a simple one).
     * This may cause the client developers to have problems with Yandex.
     */
    void simple_dencode (ref uint8[] data) {
        for (int i = 0; i < data.length; i++) {
            data[i] = data[i] ^ 0xFF;
        }
    }

    string replace_many (
        string input,
        char[] targets,
        char replacement
    ) {
        var builder = new StringBuilder ();

        for (int i = 0; i < input.length; i++) {
            if (input[i] in targets) {
                builder.append_c (replacement);
            } else {
                builder.append_c (input[i]);
            }
        }

        return builder.free_and_steal ();
    }

    string encode_name (string name) {
        return replace_many (Base64.encode (name.data), { '/', '+', '=' }, '-');
    }

    ////////////
    // Images //
    ////////////

    File get_image_cache_file (string image_uri, bool is_tmp) {
        return File.new_build_filename (
            is_tmp ? images_cachedir_file.peek_path () : images_datadir_file.peek_path (),
            encode_name (image_uri)
        );
    }

    /**
     * Get image location by it uri.
     *
     * @param   image uri
     *
     * @return  `Location` struct
     */
    public Location image_cache_location (string image_uri) {
        File image_file;

        image_file = get_image_cache_file (image_uri, false);
        if (image_file.query_exists ()) {
            return Location (false, image_file);
        }

        image_file = get_image_cache_file (image_uri, true);
        if (image_file.query_exists ()) {
            return Location (true, image_file);
        }

        return Location.none ();
    }

    public async Bytes? load_image (string image_uri) {
        Location image_location = image_cache_location (image_uri);

        if (image_location.file == null) {
            return null;
        }

        for (int i = 0; i < 5; i++) {
            try {
                uint8[] image_data;
                yield image_location.file.load_contents_async (
                    null,
                    out image_data,
                    null
                );

                simple_dencode (ref image_data);

                return new Bytes (image_data);

            } catch (Error e) {
                warning (
                    "Can't load image '%s'. Error message: %s",
                    image_location.file.peek_path (),
                    e.message
                );

                yield wait (3);
            }
        }

        warning ("Give up loading image '%s'.",
            image_location.file.peek_path ()
        );
        return null;
    }

    public async void save_image (
        Bytes image_data,
        string image_url,
        bool is_tmp = true
    ) {
        File image_file = get_image_cache_file (image_url, is_tmp);

        try {
            var dencoded_image_data = image_data.get_data ().copy ();
            simple_dencode (ref dencoded_image_data);

            yield image_file.replace_contents_async (
                dencoded_image_data,
                null,
                false,
                FileCreateFlags.NONE,
                null,
                null
            );

        } catch (Error e) {
            warning ("Can't save image %s", image_url);
        }
    }

    ////////////
    // Audios //
    ////////////

    File get_audio_cache_file (string track_id, bool is_tmp) {
        return File.new_build_filename (
            is_tmp ? audios_cachedir_file.peek_path () : audios_datadir_file.peek_path (),
            encode_name (track_id)
        );
    }

    public Location audio_cache_location (string track_id) {
        File track_file;

        track_file = get_audio_cache_file (track_id, false);
        if (track_file.query_exists ()) {
            return Location (false, track_file);
        }

        track_file = get_audio_cache_file (track_id, true);
        if (track_file.query_exists ()) {
            return Location (true, track_file);
        }

        return Location.none ();
    }

    public async Bytes? load_audio (string track_id) {
        Location audio_location = audio_cache_location (track_id);

        if (audio_location.file == null) {
            return null;
        }

        for (int i = 0; i < 5; i++) {
            try {
                uint8[] audio_data;
                yield audio_location.file.load_contents_async (
                    null,
                    out audio_data,
                    null
                );

                simple_dencode (ref audio_data);

                return new Bytes (audio_data);

            } catch (Error e) {
                warning (
                    "Can't load audio '%s'. Error message: %s",
                    audio_location.file.peek_path (),
                    e.message
                );

                yield wait (3);
            }
        }

        warning ("Give up loading track with id '%s'.",
            track_id
        );
        return null;
    }

    /**
     * Save audio data.
     *
     * @param audio_data    audio data
     * @param track_id      track's id
     * @param is_tmp        is track should be save in cache or data
     */
    public async void save_audio (
        Bytes audio,
        string track_id,
        bool is_tmp
    ) {
        File audio_file = get_audio_cache_file (track_id, is_tmp);

        try {
            var dencoded_audio_data = audio.get_data ().copy ();
            simple_dencode (ref dencoded_audio_data);

            yield audio_file.replace_contents_async (
                dencoded_audio_data,
                null,
                false,
                FileCreateFlags.NONE,
                null,
                null
            );

        } catch (Error e) {
            warning ("Can't save audio %s", track_id);
        }
    }

    /////////////
    // Objects //
    /////////////

    string build_id (Type build_type, string oid) {
        return build_type.name () + "-" + oid;
    }

    //  public async YaMAPI.HasTracks[] get_saved_objects () {
    //      var obj_arr = new Array<YaMAPI.HasTracks> ();

    //      try {
    //          FileEnumerator? enumerator = objects_datadir_file.enumerate_children (
    //              "standard::*",
    //              FileQueryInfoFlags.NONE,
    //              null
    //          );

    //          if (enumerator != null) {
    //              FileInfo? file_info = null;

    //              string filename;
    //              File file;
    //              string decoded_name;
    //              Type obj_type;

    //              while ((file_info = enumerator.next_file ()) != null) {
    //                  filename = file_info.get_name ();
    //                  file = File.new_build_filename (objects_datadir_file.peek_path (), filename);

    //                  decoded_name = (string) (Base64.decode (filename));

    //                  if ((typeof (YaMAPI.Playlist)).name () in decoded_name) {
    //                      obj_type = typeof (YaMAPI.Playlist);
    //                  } else if ((typeof (YaMAPI.Album)).name () in decoded_name) {
    //                      obj_type = typeof (YaMAPI.Album);
    //                  } else {
    //                      continue;
    //                  }

    //                  uint8[] idata;
    //                  yield file.load_contents_async (
    //                      null,
    //                      out idata,
    //                      null
    //                  );

    //                  simple_dencode (ref idata);

    //                  var jsoner = new Serialize.Jsoner.from_data (idata);

    //                  try {
    //                      obj_arr.append_val (yield jsoner.deserialize_object_async<YaMAPI.HasTracks> ());

    //                  } catch (Serialize.JsonError e) {
    //                      warning ("Can't parse object. Error message: %s", e.message);
    //                  }
    //              }
    //          }

    //      } catch (Error e) {
    //          warning (
    //              "Can't find '%s'. Error message: %s",
    //              objects_datadir_file.peek_path (),
    //              e.message
    //          );
    //      }

    //      return obj_arr.data;
    //  }

    File get_object_cache_file (
        Type obj_type,
        string oid,
        bool is_tmp
    ) {
        return File.new_build_filename (
            is_tmp ? objects_cachedir_file.peek_path () : objects_datadir_file.peek_path (),
            encode_name (build_id (obj_type, oid))
        );
    }

    public Location object_cache_location (Type obj_type, string oid) {
        File object_file;

        object_file = get_object_cache_file (obj_type, oid, false);
        if (object_file.query_exists ()) {
            return Location (false, object_file);
        }

        object_file = get_object_cache_file (obj_type, oid, true);
        if (object_file.query_exists ()) {
            return Location (true, object_file);
        }

        return Location.none ();
    }

    public async YaMAPI.HasID? load_object (Type obj_type, string oid) {
        Location object_location = object_cache_location (obj_type, oid);

        if (object_location.file == null) {
            return null;
        }

        for (int i = 0; i < 5; i++) {
            try {
                uint8[] object_data;

                yield object_location.file.load_contents_async (
                    null,
                    out object_data,
                    null
                );

                simple_dencode (ref object_data);

                var jsoner = new Serialize.Jsoner.from_data (object_data);

                YaMAPI.HasID? des_obj = null;

                try {
                    des_obj = (YaMAPI.HasID) yield jsoner.deserialize_object_by_type_async (obj_type);

                } catch (Serialize.JsonError e) {
                    warning ("Can't parse object. Error message: %s", e.message);
                }

                return des_obj;

            } catch (Error e) {
                warning (
                    "Can't load object '%s'. Error message: %s",
                    object_location.file.peek_path (),
                    e.message
                );

                yield wait (3);
            }
        }

        warning ("Give up loading object '%s'.", object_location.file.peek_path ());
        return null;
    }

    public YaMAPI.HasID? load_object_sync (Type obj_type, string oid) {
        Location object_location = object_cache_location (obj_type, oid);

        if (object_location.file == null) {
            return null;
        }

        for (int i = 0; i < 5; i++) {
            try {
                uint8[] object_data;

                object_location.file.load_contents (
                    null,
                    out object_data,
                    null
                );

                simple_dencode (ref object_data);

                var jsoner = new Serialize.Jsoner.from_data (object_data);

                YaMAPI.HasID? des_obj = null;

                try {
                    des_obj = (YaMAPI.HasID) jsoner.deserialize_object_by_type (obj_type);

                } catch (Serialize.JsonError e) {
                    warning ("Can't parse object. Error message: %s", e.message);
                }

                return des_obj;

            } catch (Error e) {}
        }

        warning ("Give up loading object '%s'.", object_location.file.peek_path ());
        return null;
    }

    public async void save_object (YaMAPI.HasID yam_object, bool is_tmp) {
        File object_file = get_object_cache_file (yam_object.get_type (), yam_object.oid, is_tmp);

        try {
            var object_data = yam_object.to_json ().data;
            simple_dencode (ref object_data);

            yield object_file.replace_contents_async (
                object_data,
                null,
                false,
                FileCreateFlags.NONE,
                null,
                null
            );

        } catch (Error e) {
            warning ("Can't save object %s", yam_object.get_type ().name ());
        }
    }

    ///////////
    // Other //
    ///////////

    public async HumanitySize get_temp_size () {
        string size = "";

        try {
            var sp = new Subprocess.newv (
                {"du", "-sh", cachedir_file.peek_path (), "--exclude=\"*.log\""},
                SubprocessFlags.STDOUT_PIPE
            );

            string? stdout_buf;
            yield sp.communicate_utf8_async (null, null, out stdout_buf, null);

            if (stdout_buf != null) {
                size = stdout_buf;
            }

            Regex regex = null;
            regex = new Regex ("^[\\d.,]+[A-Z]", RegexCompileFlags.OPTIMIZE, RegexMatchFlags.NOTEMPTY);

            MatchInfo match_info;
            if (regex.match (size, 0, out match_info)) {
                size = match_info.fetch (0);
            } else {
                size = "";
            }

        } catch (Error e) {
            warning ("Error while getting cache directory size. Error message %s", e.message);
        }

        if (size != "") {
            return to_human (size);
        } else {
            return to_human ("0B");
        }
    }

    public async HumanitySize get_perm_size () {
        string size = "";

        try {
            var sp = new Subprocess.newv (
                {"du", "-sh", datadir_file.peek_path (), "--exclude=\"*.db\"", "--exclude=\"*.cookies\""},
                SubprocessFlags.STDOUT_PIPE
            );

            string? stdout_buf;
            yield sp.communicate_utf8_async (null, null, out stdout_buf, null);

            if (stdout_buf != null) {
                size = stdout_buf;
            }

            Regex regex = null;
            regex = new Regex ("^[\\d.,]+[A-Z]", RegexCompileFlags.OPTIMIZE, RegexMatchFlags.NOTEMPTY);

            MatchInfo match_info;
            if (regex.match (size, 0, out match_info)) {
                size = match_info.fetch (0);
            } else {
                size = "";
            }

        } catch (Error e) {
           warning ("Error while getting data directory size. Error message %s", e.message);
        }

        if (size != "") {
            return to_human (size);
        } else {
            return to_human ("0B");
        }
    }
}
