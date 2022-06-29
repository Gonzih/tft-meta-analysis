include("../src/riot.jl")
using Main.Riot

leagues = ["grandmaster", "challenger", "master"]
matches = flatten(map(scrape_league, leagues))

println("Gonna scrape $(length(matches)) matches")
foreach(scrape_match, matches)
println("Scraped $(length(matches)) matches")
