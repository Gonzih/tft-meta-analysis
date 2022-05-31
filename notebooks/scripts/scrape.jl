include("../src/riot.jl")
using Main.Riot

leagues = ["challenger", "grandmaster"]
l = length(map(scrape_league, leagues))
println("Scraped $(l) requests")
