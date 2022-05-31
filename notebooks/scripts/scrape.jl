include("../src/pkgs.jl")

include("../src/riot.jl")
using Main.Riot

leagues = ["challenger", "grandmaster"]
l = length(map(scrape_league, leagues))
print("Scraped $(l) requests")
