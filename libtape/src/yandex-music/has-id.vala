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

/**
 * The interface of objects that have a unique identifier.
 * Exists because, for example, 'YaMAPI.Playlist' has
 * a composite id divided into uid and kind properties
 */
public interface Tape.YaMAPI.HasID : Serialize.DataObject {

    /**
     * Object id
     */
    public abstract string oid { owned get; }
}
