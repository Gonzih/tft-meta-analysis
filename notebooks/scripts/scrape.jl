include("../src/riot.jl")
using Main.Riot

# leagues = ["grandmaster", "challenger", "master"]
leagues = ["grandmaster", "challenger"]
l = length(map(scrape_league, leagues))
println("Scraped $(l) requests")
