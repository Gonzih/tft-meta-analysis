include("../src/riot.jl")
using Main.Riot
using DataFrames

println("Loading matches JSON")
@time df = matches_df()
println(describe(df.matches))

println("Saving matches")
@time export_all_data(df)

@time df = import_all_data(10000)
println(describe(df.matches))
println("Test loaded matches")
