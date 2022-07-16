include("../src/riot.jl")
include("../src/viz.jl")

using Main.Riot
using DataFrames
import JSON


@time rd = import_all_data(7, 8)

champs = map(Main.Viz.mapcharname, unique(rd.units.CharacterID))
items = map(Main.Viz.mapitemname, unique(rd.items.Item))
augs = map(Main.Viz.mapaugmentname, unique(rd.augments.Augment))
traits = map(Main.Viz.maptraitname, unique(rd.traits.Trait))

champ_rarity = filter(
    (r) -> r.CharacterID != "TrainerDragon",
    unique(select(rd.units, [:CharacterID, :Rarity]))
)
champ_cost = Dict(
    Main.Viz.mapcharname(r.CharacterID) => r.Rarity
    for r in eachrow(champ_rarity)
)

result = (champs = champs, items = items, augs = augs, traits = traits, champ_cost = champ_cost)


json = JSON.json(result)

open("set_data.json", "w") do io
    write(io, json)
end
