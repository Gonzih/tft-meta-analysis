module Riot

import HTTP
import JSON
using MD5
using Glob
using DataFrames
import Dates

export load_league, load_summoner, load_matches_for, load_match, scrape_match, scrape_summoner, scrape_league, all_matches_from_cache, matches_df

function riot_get(routing, path; cache_key = "get", sleep_duration = 1)
	  url = "https://$(routing).api.riotgames.com/$(path)"
    cache_fname = "cache/$(cache_key)-$(bytes2hex(md5(url))).json"

    if !isfile(cache_fname)
        print("Loading $(url) -> $(cache_fname)\n")

        sleep(sleep_duration)
        API_KEY = ENV["RIOT_API_KEY"]
	      r = HTTP.get(url, ["X-Riot-Token" => API_KEY]; verbose=0)
        open(cache_fname, "w") do io
            write(io, String(r.body))
        end
    end

    JSON.parse(open(f->read(f, String), cache_fname))
end

function load_league(league)
    riot_get("na1", "tft/league/v1/$(league)")
end

function load_summoner(id)
    riot_get("na1", "tft/summoner/v1/summoners/$(id)"; cache_key = "summoner")
end

function load_matches_for(puuid)
    riot_get("americas", "tft/match/v1/matches/by-puuid/$(puuid)/ids"; sleep_duration = 2)
end

function load_match(id)
    riot_get("americas", "tft/match/v1/matches/$(id)"; cache_key = "match")
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

function all_matches_from_cache()
    files = glob("match-*.json", "cache/")
    map((fname) -> JSON.parse(open(f->read(f, String), fname)), files)
end

struct RiotData
    participants::DataFrame
    augments::DataFrame
    traits::DataFrame
    units::DataFrame
    items::DataFrame
end

function clean_label(s::String)::String
    replace(s, "TFT6_Augment_" => "", "TFT6_" => "", "TFT_Item_" => "", "Set6_" => "")
end

function parse_match(rd::RiotData, match)
    for participant in match["info"]["participants"]
        df = DataFrame(
            Placement = participant["placement"],
            Level = participant["level"],
            DamageToPlayers = participant["total_damage_to_players"],
            LastRound = participant["last_round"],
            MatchID = match["metadata"]["match_id"],
            PUUID = participant["puuid"],
        )
        append!(rd.participants, df)

        augs = map(clean_label, participant["augments"])
        df = DataFrame(
            Augment = augs,
            MatchID = match["metadata"]["match_id"],
            PUUID = participant["puuid"],
        )
        append!(rd.augments, df)

        traits = participant["traits"]
        df = DataFrame(
            Trait = map(t -> clean_label(t["name"]), traits),
            NumUnits = map(t -> t["num_units"], traits),
            Style = map(t -> t["style"], traits),
            TierCurrent = map(t -> t["tier_current"], traits),
            TierTotal = map(t -> t["tier_total"], traits),
            MatchID = match["metadata"]["match_id"],
            PUUID = participant["puuid"],
        )
        append!(rd.traits, df)

        units = participant["units"]
        df = DataFrame(
            CharacterID = map(u -> clean_label(u["character_id"]), units),
            CharacterName = map(u -> u["name"], units),
            Rarity = map(u -> u["rarity"], units),
            Tier = map(u -> u["tier"], units),
            MatchID = match["metadata"]["match_id"],
            PUUID = participant["puuid"],
        )
        append!(rd.units, df)

        for unit in units
            itemNames = map(clean_label, unit["itemNames"])
            items = unit["items"]
            df = DataFrame(
                CharacterID = clean_label(unit["character_id"]),
                Item = itemNames,
                ItemID = items,
                MatchID = match["metadata"]["match_id"],
                PUUID = participant["puuid"],
            )
            append!(rd.items, df)
        end

    end
end

function filter_by_datetime(m, n_days)::Bool
    dt = m["info"]["game_datetime"]
    diff = Dates.value((Dates.now() - Dates.unix2datetime(dt / 1000)))
    diff = (div(diff, 1000 * 60 * 60 * 24))
    diff <= n_days
end

function matches_df(n_days::Int64)::RiotData
    files = glob("match-*.json", "cache/")
    match_data = map((fname) -> JSON.parse(open(f -> read(f, String), fname)), files)
    match_data = filter((m)->filter_by_datetime(m, n_days), match_data)

    rd = RiotData(DataFrame(), DataFrame(), DataFrame(), DataFrame(), DataFrame())
    foreach(m -> parse_match(rd, m), match_data)

    rd
end


end
