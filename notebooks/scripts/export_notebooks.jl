using Pkg
Pkg.activate(".")
Pkg.instantiate()

using PlutoSliderServer

for nb in ["meta.jl"]
    PlutoSliderServer.export_notebook(nb)
end
