module Riot

import HTTP
import JSON
using MD5
using Printf

export load_league, load_summoner, load_matches_for, load_match

API_KEY = "RGAPI-4214d6be-472d-4dbc-aaf9-d3e9456b12b7"
SLEEP = 0.1

function riot_get(routing, path)
	  url = @sprintf("https://%s.api.riotgames.com/%s", routing, path)
    cache_fname = @sprintf("cache/%s.json", bytes2hex(md5(url)))

    if !isfile(cache_fname)
        @printf "Loading %s -> %s\n" url cache_fname

        sleep(SLEEP)
	      r = HTTP.get(url, ["X-Riot-Token" => API_KEY]; verbose=0)
        open(cache_fname, "w") do io
            write(io, String(r.body))
        end
    end

    return JSON.parse(open(f->read(f, String), cache_fname))
end

function load_league(league)
    @printf "Loading league %s\n" league
    return riot_get("na1", @sprintf("tft/league/v1/%s", league))
end

function load_summoner(id)
    @printf "Loading summoner %s\n" id
    return riot_get("na1", @sprintf("tft/summoner/v1/summoners/%s", id))
end

function load_matches_for(puuid)
    @printf "Loading matches for %s\n" puuid
    return riot_get("americas", @sprintf("tft/match/v1/matches/by-puuid/%s/ids", puuid))
end

function load_match(id)
    @printf "Loading match %s\n" id
    return riot_get("americas", @sprintf("tft/match/v1/matches/%s", id))
end


end
