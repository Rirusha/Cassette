/* Copyright 2023-2024 Vladimir Vaskov
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Cassette {

    public Adw.AboutDialog build_about_dialog () {
        const string ME = "Vladimir Vaskov https://gitlab.gnome.org/Rirusha";
        const string TELEGRAM_CHAT = "https://t.me/CassetteGNOME_Discussion";
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

        var about = new Adw.AboutDialog () {
            application_name = Config.APP_NAME,
            application_icon = Config.APP_ID_DYN,
            developer_name = "Vladimir Vaskov",
            version = Config.VERSION,
            developers = developers,
            designers = designers,
            artists = artists,
            documenters = documenters,
            //  Translators: NAME <EMAIL.COM> /n NAME <EMAIL.COM>
            translator_credits = _("translator-credits"),
            license_type = Gtk.License.GPL_3_0,
            copyright = "© 2023-2024 Vladimir Vaskov",
            support_url = TELEGRAM_CHAT,
            issue_url = Config.BUGTRACKER,
            release_notes_version = Config.VERSION
        };

        about.add_link (_("Telegram channel"), TELEGRAM_CHANNEL);
        about.add_link (_("Financial support (Tinkoff)"), TINKOFF_SUPPORT_LINK);
        about.add_link (_("Financial support (Boosty)"), BOOSTY_SUPPORT_LINK);

        // Please keep alphabetical
        about.add_acknowledgement_section (_("Sponsors"), {
            "Alex Gluck",
            "Amper Shiz",
            "Anton P.",
            "AveryanAlex",
            "Avr_Iv",
            "belovmv",
            "dant4ick",
            "Dmitry M.",
            "Do6pblu_Jyk",
            "eugene_t",
            "Fiersik",
            "Fissium",
            "gen1s",
            "InDevOne",
            "IQQator",
            "Ivan A.",
            "katze_942",
            "khaustovdn",
            "krylov_alexandr",
            "kvadrozorro",
            "Mikazil E.",
            "Mikazil",
            "Mikhail Postnikov",
            "Nikolai M.",
            "Oleg Shchavelev",
            "Pavel T.",
            "Petr Chelpanov",
            "Roman Aysin",
            "Semen Fomchenkov",
            "Sergey G.",
            "Sergey P.",
            "Sergey S.",
            "Shakhrutdin Z.",
            "Spp595",
            "Tamahome",
            "Toxblh",
            "Vasily Biryukov",
            "werlock",
            "Zellrus",
        });

        return about;
    }
}
