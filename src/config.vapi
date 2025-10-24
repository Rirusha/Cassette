/*
 * Copyright (C) 2025 Vladimir Romanov <rirusha@altlinux.org>
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
 * along with this program. If not, see
 * <https://www.gnu.org/licenses/gpl-3.0-standalone.html>.
 * 
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "config.h")]
namespace Config {
    public const string APP_ID;
    public const string APP_ID_RELEVANT;
    public const string APP_NAME;
    public const string VERSION;
    public const string LAST_STABLE_VERSION;
    public const bool IS_DEVEL;
    public const string G_LOG_DOMAIN;
    public const string GETTEXT_PACKAGE;
    public const string GNOMELOCALEDIR;
    public const string DATADIR;
    public const string HOMEPAGE;
    public const string BUGTRACKER;
    public const string HELP;
}
