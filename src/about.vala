/* Copyright 2023-2024 Rirusha
 *
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
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

namespace Cassette {

    public Adw.AboutDialog build_about_dialog () {
        const string RIRUSHA = "Rirusha https://github.com/Rirusha";
        const string TELEGRAM_CHAT = "https://t.me/CassetteGNOME_Discussion";
        const string TELEGRAM_CHANNEL = "https://t.me/CassetteGNOME_Devlog";
        const string ISSUE_LINK = "https://github.com/Rirusha/Cassette/issues/new";
        const string TINKOFF_SUPPORT_LINK = "https://www.tinkoff.ru/cf/21GCxLuFuE9";
        const string BOOSTY_SUPPORT_LINK = "https://boosty.to/rirusha/donate";

        string[] developers = {
            RIRUSHA,
            "KseBooka https://github.com/KseBooka"
        };

        string[] designers = {
            RIRUSHA
        };

        string[] artists = {
            RIRUSHA,
            "Arseniy Nechkin <krisgeniusnos@gmail.com>",
            "NaumovSN",
        };

        string[] documenters = {
            RIRUSHA,
            "Armatik https://github.com/Armatik",
            "Fiersik https://github.com/fiersik",
            "Mikazil https://github.com/Mikazil",
        };

        var about = new Adw.AboutDialog () {
            application_name = Config.APP_NAME,
            application_icon = Config.APP_ID_DYN,
            developer_name = "Rirusha",
            version = Config.VERSION,
            developers = developers,
            designers = designers,
            artists = artists,
            documenters = documenters,
            //  Translators: NAME <EMAIL.COM> /n NAME <EMAIL.COM>
            translator_credits = _("translator-credits"),
            license_type = Gtk.License.GPL_3_0_ONLY,
            copyright = "© 2023-2024 Rirusha",
            support_url = TELEGRAM_CHAT,
            issue_url = ISSUE_LINK,
            release_notes_version = Config.VERSION
        };

        about.add_link (_("Telegram channel"), TELEGRAM_CHANNEL);
        about.add_link (_("Financial support (Tinkoff)"), TINKOFF_SUPPORT_LINK);
        about.add_link (_("Financial support (Boosty)"), BOOSTY_SUPPORT_LINK);

        // Please keep alphabetical
        about.add_acknowledgement_section (_("Sponsors"), {
            "Alex Gluck",
            "Amper Shiz",
            "AveryanAlex",
            "belovmv",
            "dant4ick",
            "Dmitry M.",
            "Do6pblu_Jyk",
            "eugene_t",
            "Fiersik",
            "Fissium",
            "gen1s",
            "Ivan A.",
            "IQQator",
            "katze_942",
            "khaustovdn",
            "krylov_alexandr",
            "kvadrozorro",
            "Mikazil",
            "Mikhail Postnikov",
            "Nikolai M.",
            "Oleg Shchavelev",
            "Roman Aysin",
            "Semen Fomchenkov",
            "Sergey P.",
            "Shakhrutdin Z.",
            "Spp595",
            "Toxblh",
            "Vasily Biryukov",
            "werlock",
            "Zellrus",
        });

        return about;
    }
}
