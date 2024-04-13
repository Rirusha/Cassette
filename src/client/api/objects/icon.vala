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


public class Cassette.Client.YaMAPI.Icon : YaMObject {

    public string background_color { get; set; }

    public string image_url { get; set; }

    public string get_internal_icon_name (string station_id) {
        switch (station_id) {
            case "user:onyourwave":
                return "cassette-wave-my-wave-symbolic";
            case "personal:collection":
                return "adwaita-emblem-favorite-symbolic";
            case "genre:meditation":
            case "genre:relax":
                return "cassette-wave-genre-light-music-symbolic";
            case "genre:reggaeton":
            case "genre:dub":
            case "genre:reggae":
                return "cassette-wave-genre-reggae-symbolic";
            case "genre:rusestrada":
            case "genre:estrada":
                return "cassette-wave-genre-bandstand-symbolic";
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
                return "cassette-wave-genre-rock-symbolic";
            case "genre:rusbards":
            case "genre:foreignbard":
            case "genre:bard":
                return "cassette-wave-genre-authors-song-symbolic";
            case "genre:films":
            case "genre:tvseries":
            case "genre:animated":
            case "genre:videogame":
            case "genre:animemusic":
            case "genre:musical":
            case "genre:bollywood":
            case "genre:soundtrack":
                return "cassette-wave-genre-soundtracks-symbolic";
            case "genre:vocal":
            case "genre:modern":
            case "genre:classicalmusic":
            case "genre:classicalmasterpieces":
                return "cassette-wave-genre-classic-symbolic";
            case "genre:postpunk":
            case "genre:punk":
            case "editorial:station-15":
                return "cassette-wave-genre-punk-symbolic";
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
                return "cassette-wave-genre-folk-symbolic";
            case "genre:tradjazz":
            case "genre:conjazz":
            case "genre:bebopgenre":
            case "genre:vocaljazz":
            case "genre:smoothjazz":
            case "genre:bigbands":
            case "genre:jazz":
            case "micro-genre:avant-garde-jazz":
                return "cassette-wave-genre-jazz-symbolic";
            case "genre:rusrap":
            case "genre:foreignrap":
            case "genre:rap":
            case "micro-genre:cloud-rap":
            case "micro-genre:east-coast-hip-hop":
                return "cassette-wave-genre-rap-and-hip-hop-symbolic";
            case "genre:techno":
            case "genre:phonkgenre":
            case "genre:house":
            case "genre:edmgenre":
            case "genre:trance":
            case "genre:dnb":
            case "genre:dance":
                return "cassette-wave-genre-dance-music-symbolic";
            case "genre:soul":
            case "genre:funk":
            case "genre:rnb":
                return "cassette-wave-genre-rnb-symbolic";
            case "genre:sport":
            case "activity:work-background":
                return "adwaita-audio-x-generic-symbolic";
            case "activity:study-background":
                return "cassette-wave-era-for-exam-symbolic";
            case "genre:local-indie":
            case "genre:indie":
            case "genre:folkgenre":
                return "cassette-wave-genre-indie-symbolic";
            case "genre:posthardcore":
            case "genre:hardcore":
            case "genre:alternative":
            case "personal:never-heard":
                return "cassette-wave-genre-alternative-symbolic";
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
                return "cassette-wave-genre-metal-symbolic";
            case "genre:pop":
            case "genre:ruspop":
            case "genre:disco":
            case "genre:kpop":
            case "genre:japanesepop":
            case "genre:hyperpopgenre":
                return "cassette-wave-genre-pop-symbolic";
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
            case "genre:georgian":
            case "genre:azerbaijani":
            case "genre:caucasian":
                return "cassette-wave-genre-music-of-world-symbolic";
            case "genre:children":
            case "genre:forchildren":
                return "cassette-wave-genre-childrens-music-symbolic";
            case "genre:naturesounds":
                return "cassette-wave-genre-sounds-of-nature-and-noise-of-city-symbolic";
            case "genre:soviet":
                return "cassette-wave-genre-soviet-music-symbolic";
            case "mood:aggressive":
                return "cassette-wave-mood-aggression-symbolic";
            case "mood:spring":
            case "editorial:station-19":
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
            case "personal:hits":
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
                Logger.warning ("Unknown icon with url \"https://%s\" for station id \"%s\"".printf (
                    image_url.replace ("%%", "orig"),
                    station_id
                ));

                return "io.github.Rirusha.Cassette-symbolic";
        }
    }
}
