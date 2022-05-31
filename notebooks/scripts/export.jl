include("../src/pkgs.jl")

include("../src/riot.jl")
using Main.Riot

df = matches_df(10000)
export_data(df)
