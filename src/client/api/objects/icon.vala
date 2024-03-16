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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */


namespace Cassette.Client.YaMAPI {

    /**
     * Класс иконки
     */
    public class Icon : YaMObject {

        /**
         * Цвет заднего фона в HEX
         */
        public string background_color { get; set; }

        /**
         * Ссылка на иконку
         */
        public string image_url { get; set; }

        public string get_internal_icon_name (string station_id) {
            switch (station_id) {
                case "user:onyourwave":
                    return "cassette-wave-my-wave-symbolic";
                case "personal:collection":
                    return "adwaita-emblem-favorite-symbolic";
                case "genre:meditation":
                    return "cassette-wave-genre-light-music-symbolic";
                case "genre:relax":
                    return "cassette-wave-genre-light-music-symbolic";
                case "genre:reggaeton":
                    return "cassette-wave-genre-reggae-symbolic";
                case "genre:dub":
                    return "cassette-wave-genre-reggae-symbolic";
                case "genre:reggae":
                    return "cassette-wave-genre-reggae-symbolic";
                case "genre:rusestrada":
                    return "cassette-wave-genre-bandstand-symbolic";
                case "genre:estrada":
                    return "cassette-wave-genre-bandstand-symbolic";
                case "genre:allrock":
                    return "cassette-wave-genre-rock-symbolic";
                case "genre:rusrock":
                    return "cassette-wave-genre-rock-symbolic";
                case "genre:rnr":
                    return "cassette-wave-genre-rock-symbolic";
                case "genre:pro":
                    return "cassette-wave-genre-rock-symbolic";
                case "genre:postrock":
                    return "cassette-wave-genre-rock-symbolic";
                case "genre:newwave":
                    return "cassette-wave-genre-rock-symbolic";
                case "genre:folkrock":
                    return "cassette-wave-genre-rock-symbolic";
                case "genre:stonerrock":
                    return "cassette-wave-genre-rock-symbolic";
                case "genre:hardrock":
                    return "cassette-wave-genre-rock-symbolic";
                case "genre:rock":
                    return "cassette-wave-genre-rock-symbolic";
                case "genre:rusbards":
                    return "cassette-wave-genre-authors-song-symbolic";
                case "genre:foreignbard":
                    return "cassette-wave-genre-authors-song-symbolic";
                case "genre:bard":
                    return "cassette-wave-genre-authors-song-symbolic";
                case "genre:films":
                    return "cassette-wave-genre-soundtracks-symbolic";
                case "genre:tvseries":
                    return "cassette-wave-genre-soundtracks-symbolic";
                case "genre:animated":
                    return "cassette-wave-genre-soundtracks-symbolic";
                case "genre:videogame":
                    return "cassette-wave-genre-soundtracks-symbolic";
                case "genre:animemusic":
                    return "cassette-wave-genre-soundtracks-symbolic";
                case "genre:musical":
                    return "cassette-wave-genre-soundtracks-symbolic";
                case "genre:bollywood":
                    return "cassette-wave-genre-soundtracks-symbolic";
                case "genre:soundtrack":
                    return "cassette-wave-genre-soundtracks-symbolic";
                case "genre:vocal":
                    return "cassette-wave-genre-classic-symbolic";
                case "genre:modern":
                    return "cassette-wave-genre-classic-symbolic";
                case "genre:classicalmusic":
                    return "cassette-wave-genre-classic-symbolic";
                case "genre:postpunk":
                    return "cassette-wave-genre-punk-symbolic";
                case "genre:punk":
                    return "cassette-wave-genre-punk-symbolic";
                case "editorial:station-15":
                    return "cassette-wave-genre-punk-symbolic";
                case "genre:rusfolk":
                    return "cassette-wave-genre-folk-symbolic";
                case "genre:tatar":
                    return "cassette-wave-genre-folk-symbolic";
                case "genre:celtic":
                    return "cassette-wave-genre-folk-symbolic";
                case "genre:balkan":
                    return "cassette-wave-genre-folk-symbolic";
                case "genre:eurofolk":
                    return "cassette-wave-genre-folk-symbolic";
                case "genre:jewish":
                    return "cassette-wave-genre-folk-symbolic";
                case "genre:eastern":
                    return "cassette-wave-genre-folk-symbolic";
                case "genre:african":
                    return "cassette-wave-genre-folk-symbolic";
                case "genre:folk":
                    return "cassette-wave-genre-folk-symbolic";
                case "genre:latinfolk":
                    return "cassette-wave-genre-folk-symbolic";
                case "genre:amerfolk":
                    return "cassette-wave-genre-folk-symbolic";
                case "genre:romances":
                    return "cassette-wave-genre-folk-symbolic";
                case "genre:argentinetango":
                    return "cassette-wave-genre-folk-symbolic";
                case "genre:tradjazz":
                    return "cassette-wave-genre-jazz-symbolic";
                case "genre:conjazz":
                    return "cassette-wave-genre-jazz-symbolic";
                case "genre:bebopgenre":
                    return "cassette-wave-genre-jazz-symbolic";
                case "genre:vocaljazz":
                    return "cassette-wave-genre-jazz-symbolic";
                case "genre:smoothjazz":
                    return "cassette-wave-genre-jazz-symbolic";
                case "genre:bigbands":
                    return "cassette-wave-genre-jazz-symbolic";
                case "genre:jazz":
                    return "cassette-wave-genre-jazz-symbolic";
                case "micro-genre:avant-garde-jazz":
                    return "cassette-wave-genre-jazz-symbolic";
                case "genre:rusrap":
                    return "cassette-wave-genre-rap-and-hip-hop-symbolic";
                case "genre:foreignrap":
                    return "cassette-wave-genre-rap-and-hip-hop-symbolic";
                case "genre:rap":
                    return "cassette-wave-genre-rap-and-hip-hop-symbolic";
                case "micro-genre:cloud-rap":
                    return "cassette-wave-genre-rap-and-hip-hop-symbolic";
                case "genre:techno":
                    return "cassette-wave-genre-dance-music-symbolic";
                case "genre:phonkgenre":
                    return "cassette-wave-genre-dance-music-symbolic";
                case "genre:house":
                    return "cassette-wave-genre-dance-music-symbolic";
                case "genre:edmgenre":
                    return "cassette-wave-genre-dance-music-symbolic";
                case "genre:trance":
                    return "cassette-wave-genre-dance-music-symbolic";
                case "genre:dnb":
                    return "cassette-wave-genre-dance-music-symbolic";
                case "genre:dance":
                    return "cassette-wave-genre-dance-music-symbolic";
                case "genre:soul":
                    return "cassette-wave-genre-rnb-symbolic";
                case "genre:funk":
                    return "cassette-wave-genre-rnb-symbolic";
                case "genre:rnb":
                    return "cassette-wave-genre-rnb-symbolic";
                case "genre:sport":
                    return "adwaita-audio-x-generic-symbolic";
                case "activity:study-background":
                    return "cassette-wave-era-for-exam-symbolic";
                case "activity:work-background":
                    return "adwaita-audio-x-generic-symbolic";
                case "genre:local-indie":
                    return "cassette-wave-genre-indie-symbolic";
                case "genre:indie":
                    return "cassette-wave-genre-indie-symbolic";
                case "genre:folkgenre":
                    return "cassette-wave-genre-indie-symbolic";
                case "genre:posthardcore":
                    return "cassette-wave-genre-alternative-symbolic";
                case "genre:hardcore":
                    return "cassette-wave-genre-alternative-symbolic";
                case "genre:alternative":
                    return "cassette-wave-genre-alternative-symbolic";
                case "personal:never-heard":
                    return "cassette-wave-genre-alternative-symbolic";
                case "genre:prog":
                    return "cassette-wave-genre-metal-symbolic";
                case "genre:progmetal":
                    return "cassette-wave-genre-metal-symbolic";
                case "genre:epicmetal":
                    return "cassette-wave-genre-metal-symbolic";
                case "genre:folkmetal":
                    return "cassette-wave-genre-metal-symbolic";
                case "genre:metal":
                    return "cassette-wave-genre-metal-symbolic";
                case "genre:gothicmetal":
                    return "cassette-wave-genre-metal-symbolic";
                case "genre:industrial":
                    return "cassette-wave-genre-metal-symbolic";
                case "genre:postmetal":
                    return "cassette-wave-genre-metal-symbolic";
                case "genre:sludgemetal":
                    return "cassette-wave-genre-metal-symbolic";
                case "genre:numetal":
                    return "cassette-wave-genre-metal-symbolic";
                case "genre:metalcoregenre":
                    return "cassette-wave-genre-metal-symbolic";
                case "genre:classicmetal":
                    return "cassette-wave-genre-metal-symbolic";
                case "genre:thrashmetal":
                    return "cassette-wave-genre-metal-symbolic";
                case "genre:deathmetal":
                    return "cassette-wave-genre-metal-symbolic";
                case "genre:blackmetal":
                    return "cassette-wave-genre-metal-symbolic";
                case "genre:doommetal":
                    return "cassette-wave-genre-metal-symbolic";
                case "genre:alternativemetal":
                    return "cassette-wave-genre-metal-symbolic";
                case "editorial:station-20":
                    return "cassette-wave-genre-metal-symbolic";
                case "genre:classicalmasterpieces":
                    return "cassette-wave-genre-classic-symbolic";
                case "genre:pop":
                    return "cassette-wave-genre-pop-symbolic";
                case "genre:ruspop":
                    return "cassette-wave-genre-pop-symbolic";
                case "genre:disco":
                    return "cassette-wave-genre-pop-symbolic";
                case "genre:kpop":
                    return "cassette-wave-genre-pop-symbolic";
                case "genre:japanesepop":
                    return "cassette-wave-genre-pop-symbolic";
                case "genre:hyperpopgenre":
                    return "cassette-wave-genre-pop-symbolic";
                case "genre:breakbeatgenre":
                    return "cassette-wave-genre-electronics-symbolic";
                case "genre:bassgenre":
                    return "cassette-wave-genre-electronics-symbolic";
                case "genre:electronics":
                    return "cassette-wave-genre-electronics-symbolic";
                case "genre:dubstep":
                    return "cassette-wave-genre-electronics-symbolic";
                case "genre:dubste":
                    return "cassette-wave-genre-electronics-symbolic";
                case "genre:triphopgenre":
                    return "cassette-wave-genre-electronics-symbolic";
                case "genre:ukgaragegenre":
                    return "cassette-wave-genre-electronics-symbolic";
                case "genre:idmgenre":
                    return "cassette-wave-genre-electronics-symbolic";
                case "genre:ambientgenre":
                    return "cassette-wave-genre-electronics-symbolic";
                case "genre:newage":
                    return "cassette-wave-genre-electronics-symbolic";
                case "genre:lounge":
                    return "cassette-wave-genre-electronics-symbolic";
                case "genre:experimental":
                    return "cassette-wave-genre-electronics-symbolic";
                case "genre:blues":
                    return "cassette-wave-genre-blues-symbolic";
                case "genre:ska":
                    return "cassette-wave-genre-ska-symbolic";
                case "genre:shanson":
                    return "cassette-wave-genre-chanson-symbolic";
                case "genre:country":
                    return "cassette-wave-genre-country-symbolic";
                case "genre:armenian":
                    return "cassette-wave-genre-music-of-world-symbolic";
                case "genre:georgian":
                    return "cassette-wave-genre-music-of-world-symbolic";
                case "genre:azerbaijani":
                    return "cassette-wave-genre-music-of-world-symbolic";
                case "genre:caucasian":
                    return "cassette-wave-genre-music-of-world-symbolic";
                case "genre:children":
                    return "cassette-wave-genre-childrens-music-symbolic";
                case "genre:naturesounds":
                    return "cassette-wave-genre-sounds-of-nature-and-noise-of-city-symbolic";
                case "genre:forchildren":
                    return "cassette-wave-genre-childrens-music-symbolic";
                case "genre:soviet":
                    return "cassette-wave-genre-soviet-music-symbolic";
                case "mood:aggressive":
                    return "cassette-wave-mood-aggression-symbolic";
                case "mood:spring":
                    return "cassette-wave-mood-spring-symbolic";
                case "editorial:station-19":
                    return "cassette-wave-mood-spring-symbolic";
                case "editorial:station-21":
                    return "cassette-wave-mood-spring-symbolic";
                case "mood:sad":
                    return "cassette-wave-mood-sadness-symbolic";
                case "mood:winter":
                    return "cassette-wave-mood-winter-symbolic";
                case "mood:beautiful":
                    return "cassette-wave-mood-beauty-symbolic";
                case "mood:cool":
                    return "cassette-wave-mood-cool-symbolic";
                case "mood:summer":
                    return "cassette-wave-mood-summer-symbolic";
                case "mood:dream":
                    return "cassette-wave-mood-dream-symbolic";
                case "mood:haunting":
                    return "cassette-wave-mood-mystic-symbolic";
                case "mood:dark":
                    return "cassette-wave-mood-mystic-symbolic";
                case "mood:newyear":
                    return "cassette-wave-mood-new-year-symbolic";
                case "mood:autumn":
                    return "cassette-wave-mood-autumn-symbolic";
                case "mood:happy":
                    return "cassette-wave-mood-joy-symbolic";
                case "mood:relaxed":
                    return "cassette-wave-mood-calmness-symbolic";
                case "mood:sentimental":
                    return "cassette-wave-mood-sentimental-symbolic";
                case "mood:calm":
                    return "cassette-wave-mood-calmness-symbolic";
                case "mood:energetic":
                    return "cassette-wave-mood-energetic-symbolic";
                case "mood:epic":
                    return "cassette-wave-mood-epic-symbolic";
                case "activity:wake-up":
                    return "cassette-wave-classes-wake-symbolic";
                case "activity:run":
                    return "cassette-wave-classes-run-symbolic";
                case "activity:workout":
                    return "cassette-wave-classes-workout-symbolic";
                case "activity:driving":
                    return "cassette-wave-classes-driving-symbolic";
                case "activity:road-trip":
                    return "cassette-wave-genre-sounds-of-nature-and-noise-of-city-symbolic";
                case "activity:party":
                    return "cassette-wave-classes-party-symbolic";
                case "activity:romantic-date":
                    return "cassette-wave-classes-date-symbolic";
                case "activity:beloved":
                    return "cassette-wave-classes-for-lovers-symbolic";
                case "activity:sex":
                    return "cassette-wave-classes-sex-symbolic";
                case "activity:fall-asleep":
                    return "cassette-wave-classes-sleep-symbolic";
                case "epoch:the-greatest-hits":
                    return "cassette-wave-era-eternal-hits-symbolic";
                case "personal:hits":
                    return "cassette-wave-era-eternal-hits-symbolic";
                case "editorial:station-18":
                    return "cassette-wave-era-eternal-hits-symbolic";
                case "epoch:fifties":
                    return "cassette-wave-era-1950s-symbolic";
                case "epoch:sixties":
                    return "cassette-wave-era-1960s-symbolic";
                case "epoch:seventies":
                    return "cassette-wave-era-1970s-symbolic";
                case "epoch:eighties":
                    return "cassette-wave-era-1980s-symbolic";
                case "epoch:nineties":
                    return "cassette-wave-era-1990s-symbolic";
                case "epoch:zeroes":
                    return "cassette-wave-era-2000s-symbolic";
                case "epoch:tenths":
                    return "cassette-wave-era-2010s-symbolic";
                case "epoch:twenties":
                    return "cassette-wave-era-2020s-symbolic";
                case "personal:missed-likes":
                    return "cassette-not-like-symbolic";
                case "editorial:station-1":
                    return "cassette-wave-era-tales-for-sleeping-symbolic";
                case "editorial:station-4":
                    return "cassette-wave-era-tales-for-sleeping-symbolic";
                case "editorial:station-5":
                    return "cassette-wave-era-forks-symbolic";
                case "editorial:station-13":
                    return "cassette-wave-era-new-years-tales-symbolic";
                case "editorial:station-14":
                    return "cassette-wave-era-childrens-new-year-songs-symbolic";
                case "editorial:station-16":
                    return "cassette-wave-era-white-noise-symbolic";
                case "editorial:station-17":
                    return "cassette-wave-era-lullaby-symbolic";
                default:
                    Logger.warning ("Unknown icon with url \"%s\" for station id \"%s\"".printf (image_url, station_id));

                    return "io.github.Rirusha.Cassette-symbolic";
            }
        }
    }
}
