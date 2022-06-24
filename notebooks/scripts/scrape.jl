include("../src/riot.jl")
using Main.Riot

leagues = ["grandmaster", "challenger", "master"]
l = length(map(scrape_league, leagues))
println("Scraped $(l) requests")
