include("../src/pgks.jl")
using PlutoSliderServer

for nb in ["/notebooks/meta.jl"]
    PlutoSliderServer.export_notebook(nb)
end
