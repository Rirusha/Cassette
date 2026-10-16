/*
 * Copyright (C) 2026 Vladimir Romanov <rirusha@altlinux.org>
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

const string TEST_APP_NAME = "CassetteStoragerTest";

File test_root;
Tape.Client test_client;
Tape.Storager storager;

void cleanup_dir (File dir) {
    if (!dir.query_exists ()) {
        return;
    }

    try {
        var enumerator = dir.enumerate_children (
            FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE,
            FileQueryInfoFlags.NONE
        );
        FileInfo info;
        while ((info = enumerator.next_file ()) != null) {
            var child = dir.get_child (info.get_name ());
            if (info.get_file_type () == FileType.DIRECTORY) {
                cleanup_dir (child);
            } else {
                child.delete ();
            }
        }
        dir.delete ();
    } catch (Error e) {
        Test.fail_printf ("Failed to cleanup: %s", e.message);
    }
}

void assert_bytes_equal (Bytes? actual, uint8[] expected, string description) {
    if (actual == null) {
        Test.fail_printf ("Expected %s to be loaded", description);
        return;
    }

    unowned uint8[] actual_data = actual.get_data ();
    if (actual_data.length != expected.length) {
        Test.fail_printf (
            "Expected %s length %d, got %d",
            description,
            expected.length,
            actual_data.length
        );
        return;
    }

    for (int i = 0; i < expected.length; i++) {
        if (actual_data[i] != expected[i]) {
            Test.fail_printf (
                "Expected %s byte %d to be %u, got %u",
                description,
                i,
                expected[i],
                actual_data[i]
            );
            return;
        }
    }
}

void test_storage_dirs () {
    var expected_data_dir = Path.build_filename (
        Environment.get_variable ("XDG_DATA_HOME"),
        TEST_APP_NAME.down ()
    );
    var expected_cache_dir = Path.build_filename (
        Environment.get_variable ("XDG_CACHE_HOME"),
        TEST_APP_NAME.down ()
    );

    if (storager.datadir_file.get_path () != expected_data_dir) {
        Test.fail_printf (
            "Expected data dir '%s', got '%s'",
            expected_data_dir,
            storager.datadir_file.get_path ()
        );
    }
    if (storager.cachedir_file.get_path () != expected_cache_dir) {
        Test.fail_printf (
            "Expected cache dir '%s', got '%s'",
            expected_cache_dir,
            storager.cachedir_file.get_path ()
        );
    }

    File[] dirs = {
        storager.datadir_file,
        storager.images_datadir_file,
        storager.audios_datadir_file,
        storager.objects_datadir_file,
        storager.cachedir_file,
        storager.images_cachedir_file,
        storager.audios_cachedir_file,
        storager.objects_cachedir_file,
    };
    foreach (var dir in dirs) {
        if (dir.query_file_type (FileQueryInfoFlags.NONE) != FileType.DIRECTORY) {
            Test.fail_printf ("Expected '%s' to be a directory", dir.get_path ());
        }
    }
}

async void test_save_load_image () {
    uint8[] expected = { 0, 1, 2, 127, 255 };
    var uri = "https://example.test/cover/image.jpg";

    if (storager.image_cache_location (uri).file != null) {
        Test.fail_printf ("Expected image cache location to be empty before save");
    }

    yield storager.save_image (new Bytes (expected), uri, true);

    var location = storager.image_cache_location (uri);
    if (location.file == null || !location.is_tmp) {
        Test.fail_printf ("Expected saved image to have a temporary cache location");
    }

    assert_bytes_equal (yield storager.load_image (uri), expected, "image");
}

async void test_save_load_audio () {
    uint8[] expected = { 255, 128, 64, 32, 0 };
    var track_id = "track/with+unsafe=characters";

    if (storager.audio_cache_location (track_id).file != null) {
        Test.fail_printf ("Expected audio cache location to be empty before save");
    }

    yield storager.save_audio (new Bytes (expected), track_id, false);

    var location = storager.audio_cache_location (track_id);
    if (location.file == null || location.is_tmp) {
        Test.fail_printf ("Expected saved audio to have a permanent cache location");
    }

    assert_bytes_equal (yield storager.load_audio (track_id), expected, "audio");
}

public static int main (string[] args) {
    string path;
    try {
        path = DirUtils.make_tmp ("cassette-storager-XXXXXX");
    } catch (FileError e) {
        Test.fail_printf ("Failed to create temp dir: %s", e.message);
        return 1;
    }

    test_root = File.new_for_path (path);
    Environment.set_variable (
        "XDG_DATA_HOME",
        test_root.get_child ("data").get_path (),
        true
    );
    Environment.set_variable (
        "XDG_CACHE_HOME",
        test_root.get_child ("cache").get_path (),
        true
    );

    test_client = new Tape.Client (
        new Tape.Settings (TEST_APP_NAME, "space.rirusha.Cassette.StoragerTest")
    );
    storager = test_client.cm.storager;

    Test.init (ref args);

    Test.add_func ("/storager/directories/xdg-layout", test_storage_dirs);
    Test.add_func ("/storager/images/save-load", () => {
        var loop = new MainLoop ();
        test_save_load_image.begin (() => {
            loop.quit ();
        });
        loop.run ();
    });
    Test.add_func ("/storager/audios/save-load", () => {
        var loop = new MainLoop ();
        test_save_load_audio.begin (() => {
            loop.quit ();
        });
        loop.run ();
    });

    var result = Test.run ();
    cleanup_dir (test_root);
    return result;
}
