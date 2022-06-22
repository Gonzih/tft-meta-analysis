include("../src/riot.jl")

using Main.Riot
using DataFrames

println("Loading matches JSON")
@time df = matches_df()
println(describe(df.matches))

println("Saving matches")
@time export_all_data(df)
