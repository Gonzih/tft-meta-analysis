import Pkg

import Pkg
Pkg.add("PlutoSliderServer")

using PlutoSliderServer

PlutoSliderServer.run_directory("/notebooks"; SliderServer_host="0.0.0.0")
