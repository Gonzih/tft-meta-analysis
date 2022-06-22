using Pkg
Pkg.activate(".")
Pkg.instantiate()

using PlutoSliderServer

for nb in ["/notebooks/meta.jl"]
    PlutoSliderServer.export_notebook(nb)
end
