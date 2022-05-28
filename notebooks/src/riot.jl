module Riot

import HTTP
import JSON
using MD5
using Printf

export load_league, load_summoner, load_matches_for, load_match, scrape_match, scrape_summoner, scrape_league

SLEEP = 1

function riot_get(routing, path; cache_key = "get")
	  url = @sprintf("https://%s.api.riotgames.com/%s", routing, path)
    cache_fname = @sprintf("cache/%s-%s.json", cache_key, bytes2hex(md5(url)))

    if !isfile(cache_fname)
        @printf "Loading %s -> %s\n" url cache_fname

        sleep(SLEEP)
        API_KEY = ENV["RIOT_API_KEY"]
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
    return riot_get("americas", @sprintf("tft/match/v1/matches/%s", id); cache_key = "match")
end


# SCRAPING FNS

function scrape_match(id)
    mdata = load_match(id)
    mdata
end

function scrape_summoner(data)
    id = data["summonerId"]
    sdata = load_summoner(id)
    puuid = sdata["puuid"]
    matches = load_matches_for(puuid)
    map(scrape_match, matches)
end

function scrape_league(l)
    ldata = load_league(l)
    map(scrape_summoner, ldata["entries"])
end


end
