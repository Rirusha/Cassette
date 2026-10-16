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

File create_temp_dir () {
    string path;
    try {
        path = DirUtils.make_tmp ("cassette-info-db-XXXXXX");
    } catch (FileError e) {
        Test.fail_printf ("Failed to create temp dir: %s", e.message);
        return File.new_for_path ("");
    }
    return File.new_for_path (path);
}

void cleanup_dir (File dir) {
    try {
        var enumerator = dir.enumerate_children (
            FileAttribute.STANDARD_NAME,
            FileQueryInfoFlags.NONE
        );
        FileInfo info;
        while ((info = enumerator.next_file ()) != null) {
            dir.get_child (info.get_name ()).delete ();
        }
        dir.delete ();
    } catch (Error e) {
        Test.fail_printf ("Failed to cleanup: %s", e.message);
    }
}

Tape.InfoDB create_test_db (File dir) {
    return new Tape.InfoDB (dir.get_child ("info.db").get_path ());
}

void test_additional_data () {
    var dir = create_temp_dir ();
    var db = create_test_db (dir);

    if (db.get_additional_data ("missing") != null) {
        Test.fail_printf ("Expected missing additional data to be null");
    }

    db.set_additional_data ("key", "first");
    if (db.get_additional_data ("key") != "first") {
        Test.fail_printf ("Expected additional data to be 'first'");
    }

    db.set_additional_data ("key", "second");
    if (db.get_additional_data ("key") != "second") {
        Test.fail_printf ("Expected additional data to be replaced with 'second'");
    }

    cleanup_dir (dir);
}

void test_content_refs () {
    var dir = create_temp_dir ();
    var db = create_test_db (dir);

    if (db.get_content_ref_count ("track") != 0) {
        Test.fail_printf ("Expected a new content ref count to be 0");
    }

    db.set_content_ref ("track", "playlist-a");
    db.set_content_ref ("track", "playlist-a");
    db.set_content_ref ("track", "playlist-b");

    if (db.get_content_ref_count ("track") != 2) {
        Test.fail_printf ("Expected duplicate content refs to be ignored");
    }
    if (db.get_content_ref_count ("track", "playlist-a") != 1) {
        Test.fail_printf ("Expected a source-specific content ref count to be 1");
    }

    db.remove_content_ref ("track", "playlist-a");
    if (db.get_content_ref_count ("track") != 1) {
        Test.fail_printf ("Expected one content ref after removal");
    }
    if (db.get_content_ref_count ("track", "playlist-a") != 0) {
        Test.fail_printf ("Expected removed content ref to be absent");
    }

    cleanup_dir (dir);
}

public static int main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/info-db/additional-data/set-get-replace", test_additional_data);
    Test.add_func ("/info-db/content-refs/add-duplicate-remove", test_content_refs);

    return Test.run ();
}
