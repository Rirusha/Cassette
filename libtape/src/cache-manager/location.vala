/*
 * Copyright 2024 Vladimir Romanov
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

public struct Tape.Location {

    public bool is_tmp { get; private set; }

    public File? file { get; private set; }

    public Location (bool is_tmp, File? file) {
        this.is_tmp = is_tmp;
        this.file = file;
    }

    public Location.none () {
        this.is_tmp = true;
        this.file = null;
    }
}
