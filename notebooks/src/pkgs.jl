using Pkg
Pkg.add(["IJulia", "Pluto", "PlutoSliderServer", "PyPlot", "ProgressMeter", "JSON", "HTTP", "MD5", "Glob", "Pipe", "DataStructures", "Gadfly", "DataFrames", "FreqTables", "CSV"])

Pkg.build("IJulia")
