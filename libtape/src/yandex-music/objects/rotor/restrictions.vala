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

/**
 * YaMAPIRotorWave parameters
 */
public class Tape.YaMAPIRotorRestrictions : Deser.DataObject {

    /**
     * YaMAPIRotorWave language
     */
    public YaMAPIRotorValueHeap language { get; set; }

    /**
     * YaMAPIRotorWave diversity
     */
    public YaMAPIRotorValueHeap diversity { get; set; }

    /**
     * YaMAPIRotorWave mood
     */
    public YaMAPIRotorValueHeap mood { get; set; }

    /**
     * YaMAPIRotorWave energy
     */
    public YaMAPIRotorValueHeap energy { get; set; }

    /**
     * YaMAPIRotorWave mood and energy
     */
    public YaMAPIRotorValueHeap mood_energy { get; set; }
}
