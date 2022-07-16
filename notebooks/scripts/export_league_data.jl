include("../src/riot.jl")

using Main.Riot
using DataFrames


@time data = import_all_data(7, 8)

println(data)
