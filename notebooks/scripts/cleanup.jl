include("../src/riot.jl")

using Main.Riot
using DataFrames

println("Removing old matches")
@time rm_old_data(7)
