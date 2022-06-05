### A Pluto.jl notebook ###
# v0.19.5

using Markdown
using InteractiveUtils

# ╔═╡ d48629d6-386b-4d5d-9458-c0521f472151
	pwd = readchomp(`pwd`)

# ╔═╡ 60f02ac5-0658-4cdb-ac9c-716a46369fe5
begin
	using HypertextLiteral
	url = "/open?path=$(pwd)/repo/notebooks/comp_selector.jl"
	@htl("<a href=$(url) target=_blank>OPEN</a>")
end

# ╔═╡ a53c5870-76a6-4676-9b36-164ad63757a1
if !isdir("./repo")
	run(`git clone https://github.com/Gonzih/tft-meta-analysis.git $(pwd)/repo`)
end

# ╔═╡ c42e3e8c-e4fb-11ec-0a0f-cd41599b9f46
module packages include("repo/notebooks/src/pkgs.jl") end

# ╔═╡ 23a101b0-46a8-4c4f-a0f4-8aab9a6c39b3
module riot include("repo/notebooks/src/riot.jl") end

# ╔═╡ 35fe3d96-057e-43db-9141-4b12c6606887
if !riot.Riot.is_data_present()
	run(`cd repo && make unpack-data`)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"

[compat]
HypertextLiteral = "~0.9.4"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"
"""

# ╔═╡ Cell order:
# ╠═d48629d6-386b-4d5d-9458-c0521f472151
# ╠═a53c5870-76a6-4676-9b36-164ad63757a1
# ╠═c42e3e8c-e4fb-11ec-0a0f-cd41599b9f46
# ╠═23a101b0-46a8-4c4f-a0f4-8aab9a6c39b3
# ╠═35fe3d96-057e-43db-9141-4b12c6606887
# ╠═60f02ac5-0658-4cdb-ac9c-716a46369fe5
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
