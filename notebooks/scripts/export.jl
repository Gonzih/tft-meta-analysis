include("../src/riot.jl")

using Main.Riot
using DataFrames

println("Loading matches JSON")
@time df = matches_df()

dfrows = nrows(df.matches)
println("Saving $(dfrows) matches")
@time export_all_data(df)
