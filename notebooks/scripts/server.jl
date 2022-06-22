using Pkg
Pkg.activate(".")
Pkg.instantiate()

using PlutoSliderServer

PlutoSliderServer.run_directory("/notebooks"; SliderServer_host="0.0.0.0")
