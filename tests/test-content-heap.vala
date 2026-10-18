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

class TestContentHeap : Tape.ContentHeap {

    public int local_requests { get; private set; default = 0; }

    protected override async Tape.Content? get_local_content (string id) {
        local_requests++;
        return new Tape.Content (id);
    }

    protected override async Tape.Content? get_remote_content (string id) {
        Test.fail_printf ("Unexpected remote request for '%s'", id);
        return null;
    }
}

async void test_release_after_last_reference () {
    var heap = new TestContentHeap ();
    Tape.Content? first = yield heap.get_content ("content-id");
    Tape.Content? second = yield heap.get_content ("content-id");

    if (first == null || second == null) {
        Test.fail_printf ("Expected heap to return content");
        return;
    }
    if (first != second) {
        Test.fail_printf ("Expected heap to reuse referenced content");
    }
    if (heap.local_requests != 1) {
        Test.fail_printf ("Expected one local request, got %d", heap.local_requests);
    }

    var weak_content = WeakRef (first);

    first = null;
    if (weak_content.get () == null) {
        Test.fail_printf ("Expected content to stay alive while one reference remains");
        return;
    }

    second = null;
    if (weak_content.get () != null) {
        Test.fail_printf ("Expected content to be released after the last reference was removed");
        return;
    }

    var replacement = yield heap.get_content ("content-id");
    if (replacement == null) {
        Test.fail_printf ("Expected heap to recreate released content");
    }
    if (heap.local_requests != 2) {
        Test.fail_printf (
            "Expected a second local request after release, got %d",
            heap.local_requests
        );
    }
}

public static int main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/content-heap/references/release-after-last-reference", () => {
        var loop = new MainLoop ();
        test_release_after_last_reference.begin (() => {
            loop.quit ();
        });
        loop.run ();
    });

    return Test.run ();
}
