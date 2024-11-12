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


public class Cassette.Client.YaMAPI.Icon : YaMObject {

    public string background_color { get; set; }

    public string image_url { get; set; default = ""; }

    public string get_internal_icon_name (string station_id) {
        switch (station_id) {
            case "user:onyourwave":
                return "wave-my-wave-symbolic";
            case "personal:collection":
                return "emblem-favorite-symbolic";
            case "genre:meditation":
            case "genre:relax":
                return "wave-genre-light-music-symbolic";
            case "genre:reggaeton":
            case "genre:dub":
            case "genre:reggae":
                return "wave-genre-reggae-symbolic";
            case "genre:rusestrada":
            case "genre:estrada":
                return "wave-genre-bandstand-symbolic";
            case "genre:allrock":
            case "genre:rusrock":
            case "genre:rnr":
            case "genre:pro":
            case "genre:postrock":
            case "genre:newwave":
            case "genre:folkrock":
            case "genre:stonerrock":
            case "genre:hardrock":
            case "genre:rock":
                return "wave-genre-rock-symbolic";
            case "genre:rusbards":
            case "genre:foreignbard":
            case "genre:bard":
                return "wave-genre-authors-song-symbolic";
            case "genre:films":
            case "genre:tvseries":
            case "genre:animated":
            case "genre:videogame":
            case "genre:animemusic":
            case "genre:musical":
            case "genre:bollywood":
            case "genre:soundtrack":
                return "wave-genre-soundtracks-symbolic";
            case "genre:vocal":
            case "genre:modern":
            case "genre:classicalmusic":
            case "genre:classicalmasterpieces":
                return "wave-genre-classic-symbolic";
            case "genre:postpunk":
            case "genre:punk":
            case "editorial:station-15":
                return "wave-genre-punk-symbolic";
            case "genre:rusfolk":
            case "genre:tatar":
            case "genre:celtic":
            case "genre:balkan":
            case "genre:eurofolk":
            case "genre:jewish":
            case "genre:eastern":
            case "genre:african":
            case "genre:folk":
            case "genre:latinfolk":
            case "genre:amerfolk":
            case "genre:romances":
            case "genre:argentinetango":
                return "wave-genre-folk-symbolic";
            case "genre:tradjazz":
            case "genre:conjazz":
            case "genre:bebopgenre":
            case "genre:vocaljazz":
            case "genre:smoothjazz":
            case "genre:bigbands":
            case "genre:jazz":
            case "micro-genre:avant-garde-jazz":
                return "wave-genre-jazz-symbolic";
            case "genre:rusrap":
            case "genre:foreignrap":
            case "genre:rap":
            case "micro-genre:cloud-rap":
            case "micro-genre:east-coast-hip-hop":
                return "wave-genre-rap-and-hip-hop-symbolic";
            case "genre:techno":
            case "genre:phonkgenre":
            case "genre:house":
            case "genre:edmgenre":
            case "genre:trance":
            case "genre:dnb":
            case "genre:dance":
                return "wave-genre-dance-music-symbolic";
            case "genre:soul":
            case "genre:funk":
            case "genre:rnb":
                return "wave-genre-rnb-symbolic";
            case "genre:sport":
            case "activity:work-background":
                return "audio-x-generic-symbolic";
            case "activity:study-background":
                return "wave-era-for-exam-symbolic";
            case "genre:local-indie":
            case "genre:indie":
            case "genre:folkgenre":
                return "wave-genre-indie-symbolic";
            case "genre:posthardcore":
            case "genre:hardcore":
            case "genre:alternative":
            case "personal:never-heard":
                return "wave-genre-alternative-symbolic";
            case "genre:prog":
            case "genre:progmetal":
            case "genre:epicmetal":
            case "genre:folkmetal":
            case "genre:metal":
            case "genre:gothicmetal":
            case "genre:industrial":
            case "genre:postmetal":
            case "genre:sludgemetal":
            case "genre:numetal":
            case "genre:metalcoregenre":
            case "genre:classicmetal":
            case "genre:thrashmetal":
            case "genre:deathmetal":
            case "genre:blackmetal":
            case "genre:doommetal":
            case "genre:alternativemetal":
            case "editorial:station-20":
                return "wave-genre-metal-symbolic";
            case "genre:pop":
            case "genre:ruspop":
            case "genre:disco":
            case "genre:kpop":
            case "genre:japanesepop":
            case "genre:hyperpopgenre":
                return "wave-genre-pop-symbolic";
            case "genre:breakbeatgenre":
            case "genre:bassgenre":
            case "genre:electronics":
            case "genre:dubstep":
            case "genre:dubste":
            case "genre:triphopgenre":
            case "genre:ukgaragegenre":
            case "genre:idmgenre":
            case "genre:ambientgenre":
            case "genre:newage":
            case "genre:lounge":
            case "genre:experimental":
                return "wave-genre-electronics-symbolic";
            case "genre:blues":
                return "wave-genre-blues-symbolic";
            case "genre:ska":
                return "wave-genre-ska-symbolic";
            case "genre:shanson":
                return "wave-genre-chanson-symbolic";
            case "genre:country":
                return "wave-genre-country-symbolic";
            case "genre:armenian":
            case "genre:georgian":
            case "genre:azerbaijani":
            case "genre:caucasian":
                return "wave-genre-music-of-world-symbolic";
            case "genre:children":
            case "genre:forchildren":
                return "wave-genre-childrens-music-symbolic";
            case "genre:naturesounds":
                return "wave-genre-sounds-of-nature-and-noise-of-city-symbolic";
            case "genre:soviet":
                return "wave-genre-soviet-music-symbolic";
            case "mood:aggressive":
                return "wave-mood-aggression-symbolic";
            case "mood:spring":
            case "editorial:station-19":
            case "editorial:station-21":
                return "wave-mood-spring-symbolic";
            case "mood:sad":
                return "wave-mood-sadness-symbolic";
            case "mood:winter":
                return "wave-mood-winter-symbolic";
            case "mood:beautiful":
                return "wave-mood-beauty-symbolic";
            case "mood:cool":
                return "wave-mood-cool-symbolic";
            case "mood:summer":
                return "wave-mood-summer-symbolic";
            case "mood:dream":
                return "wave-mood-dream-symbolic";
            case "mood:haunting":
                return "wave-mood-mystic-symbolic";
            case "mood:dark":
                return "wave-mood-mystic-symbolic";
            case "mood:newyear":
                return "wave-mood-new-year-symbolic";
            case "mood:autumn":
                return "wave-mood-autumn-symbolic";
            case "mood:happy":
                return "wave-mood-joy-symbolic";
            case "mood:relaxed":
                return "wave-mood-calmness-symbolic";
            case "mood:sentimental":
                return "wave-mood-sentimental-symbolic";
            case "mood:calm":
                return "wave-mood-calmness-symbolic";
            case "mood:energetic":
                return "wave-mood-energetic-symbolic";
            case "mood:epic":
                return "wave-mood-epic-symbolic";
            case "activity:wake-up":
                return "wave-classes-wake-symbolic";
            case "activity:run":
                return "wave-classes-run-symbolic";
            case "activity:workout":
                return "wave-classes-workout-symbolic";
            case "activity:driving":
                return "wave-classes-driving-symbolic";
            case "activity:road-trip":
                return "wave-genre-sounds-of-nature-and-noise-of-city-symbolic";
            case "activity:party":
                return "wave-classes-party-symbolic";
            case "activity:romantic-date":
                return "wave-classes-date-symbolic";
            case "activity:beloved":
                return "wave-classes-for-lovers-symbolic";
            case "activity:sex":
                return "wave-classes-sex-symbolic";
            case "activity:fall-asleep":
                return "wave-classes-sleep-symbolic";
            case "epoch:the-greatest-hits":
            case "personal:hits":
            case "editorial:station-18":
                return "wave-era-eternal-hits-symbolic";
            case "epoch:fifties":
                return "wave-era-1950s-symbolic";
            case "epoch:sixties":
                return "wave-era-1960s-symbolic";
            case "epoch:seventies":
                return "wave-era-1970s-symbolic";
            case "epoch:eighties":
                return "wave-era-1980s-symbolic";
            case "epoch:nineties":
                return "wave-era-1990s-symbolic";
            case "epoch:zeroes":
                return "wave-era-2000s-symbolic";
            case "epoch:tenths":
                return "wave-era-2010s-symbolic";
            case "epoch:twenties":
                return "wave-era-2020s-symbolic";
            case "personal:missed-likes":
                return "not-like-symbolic";
            case "editorial:station-1":
            case "editorial:station-4":
                return "wave-era-tales-for-sleeping-symbolic";
            case "editorial:station-5":
                return "wave-era-forks-symbolic";
            case "editorial:station-13":
                return "wave-era-new-years-tales-symbolic";
            case "editorial:station-14":
                return "wave-era-childrens-new-year-songs-symbolic";
            case "editorial:station-16":
                return "wave-era-white-noise-symbolic";
            case "editorial:station-17":
                return "wave-era-lullaby-symbolic";
            default:
                Logger.devel ("Unknown icon with url \"https://%s\" for station id \"%s\"".printf (
                    image_url.replace ("%%", "orig"),
                    station_id
                ));

                return "music-note-symbolic";
        }
    }
}
