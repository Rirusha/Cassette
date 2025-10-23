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

namespace Cassette {

    Adw.AboutDialog build_about () {
        const string ME = "Vladimir Romanov <rirusha@altlinux.org>";
        const string TELEGRAM_CHANNEL = "https://t.me/CassetteGNOME_Devlog";
        const string TINKOFF_SUPPORT_LINK = "https://www.tinkoff.ru/cf/21GCxLuFuE9";
        const string BOOSTY_SUPPORT_LINK = "https://boosty.to/rirusha/donate";

        string[] developers = {
            ME,
            "KseBooka https://github.com/KseBooka"
        };

        string[] designers = {
            ME
        };

        string[] artists = {
            ME,
            "Arseniy Nechkin <krisgeniusnos@gmail.com>",
            "NaumovSN",
        };

        string[] documenters = {
            ME,
            "Armatik https://github.com/Armatik",
            "Fiersik https://github.com/fiersik",
            "Mikazil https://github.com/Mikazil",
        };

        string[] sponsors = {
            "Alex Gluck",
            "Andrey",
            "AveryanAlex",
            "Avr_Iv",
            "belovmv",
            "dant4ick",
            "eugene_t",
            "Fissium",
            "gen1s",
            "Hikeri",
            "InDevOne",
            "katze_942",
            "khaustovdn",
            "krylov_alexandr",
            "kvadrozorro",
            "Mikazil",
            "Mikhail E.",
            "Mikhail Postnikov",
            "Roman Aysin",
            "Spp595",
            "Tamahome",
            "werlock",
            "Александр Ляпунов (aka Do6pblu_Jyk)",
            "Алексей Б.",
            "Алексей Швец (aka Zellrus)",
            "Антон П.",
            "Антон Пальгунов (aka Toxblh)",
            "Антон Политов (aka Amper Shiz)",
            "Василий Бирюков",
            "Владимир В.",
            "Дмитрий М.",
            "Дмитрий Ч.",
            "Иван А.",
            "Кирилл Уницаев (aka Fiersik)",
            "Ник",
            "Николай М.",
            "Олег Щавелев",
            "Павел Субач (aka IQQator)",
            "Павел Т.",
            "Пётр Челпанов",
            "Семён Фомченков (Armatik)",
            "Сергей Г.",
            "Сергей П.",
            "Сергей С.",
            "Шахрутдин З.",
        };

        var about = new Adw.AboutDialog.from_appdata (
            "/space/rirusha/Cassette/space.rirusha.Cassette.metainfo.xml",
            Config.VERSION
        ) {
            application_icon = Config.APP_ID_RELEVANT,
            artists = artists,
            developers = developers,
            documenters = documenters,
            designers = designers,
            version = Config.VERSION,
            // Translators: NAME <EMAIL.COM> /n NAME <EMAIL.COM>
            translator_credits = _("translator-credits"),
            copyright = "© 2023-2025 %s".printf (_("Vladimir Romanov"))
        };

        about.add_link (_("Telegram channel"), TELEGRAM_CHANNEL);
        about.add_link (_("Financial support (Tinkoff)"), TINKOFF_SUPPORT_LINK);
        about.add_link (_("Financial support (Boosty)"), BOOSTY_SUPPORT_LINK);

        about.add_acknowledgement_section (_("Sponsors"), sponsors);

        return about;
    }
}
