### A Pluto.jl notebook ###
# v0.19.8

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 7d3b92bc-e204-11ec-1da7-f5f3d36f2b35
begin
	#using PyPlot
	#using Pipe
	#using Gadfly
	using FreqTables
	using DataFrames
	using HypertextLiteral
	using Random
	using PlutoUI

	#Gadfly.push_theme(:dark)
	
	"dependencies"
end

# ╔═╡ 7bc24ef4-e910-4651-8ca4-2c012b670161
begin
	waveform = @htl("""
	<style>
	.waveform {
	  --uib-size: 40px;
	  --uib-speed: 1s;
	  --uib-color: white;
	  --uib-line-weight: 3.5px;
	
	  display: flex;
	  flex-flow: row nowrap;
	  align-items: center;
	  justify-content: space-between;
	  width: var(--uib-size);
	  height: calc(var(--uib-size) * 0.9);
	}
	
	.waveform__bar {
	  width: var(--uib-line-weight);
	  height: 100%;
	  background-color: var(--uib-color);
	}
	
	.waveform__bar:nth-child(1) {
	  animation: grow var(--uib-speed) ease-in-out
	    calc(var(--uib-speed) * -0.45) infinite;
	}
	
	.waveform__bar:nth-child(2) {
	  animation: grow var(--uib-speed) ease-in-out
	    calc(var(--uib-speed) * -0.3) infinite;
	}
	
	.waveform__bar:nth-child(3) {
	  animation: grow var(--uib-speed) ease-in-out
	    calc(var(--uib-speed) * -0.15) infinite;
	}
	
	.waveform__bar:nth-child(4) {
	  animation: grow var(--uib-speed) ease-in-out infinite;
	}
	
	@keyframes grow {
	  0%,
	  100% {
	    transform: scaleY(0.3);
	  }
	
	  50% {
	    transform: scaleY(1);
	  }
	}
	</style>
	<div class="waveform">
	  <div class="waveform__bar"></div>
	  <div class="waveform__bar"></div>
	  <div class="waveform__bar"></div>
	  <div class="waveform__bar"></div>
	</div>
	""")
	
	"waveform icon"
end

# ╔═╡ 861f00e8-c967-4281-9b12-0b510082580d
@htl("""
<style>
.icon {
	width: 32px;
	height: 32px;
	border-width: 1px;
	border-style: solid;
	border-color: rgba(255, 255, 255, 0);
}
.centered {
	display: flex;
	justify-content: center;
	align-items: center;
}
</style>
Styles are here
""")

# ╔═╡ 3731faa2-4d9f-4d98-b095-781a7c2464c1
module riot include("src/riot.jl") end

# ╔═╡ 3830b19e-3365-4f30-9e93-3304fe5a345b
begin
	f = @bind n_days NumberField(1:30; default = 7)
	md"""
	### Select only matches from the last $(f) days
	"""
end

# ╔═╡ 80a9b48a-ff99-449c-ba6e-309ced8e5726
begin
	placement_f = @bind placement_cutoff NumberField(1:8; default = 3)
	md"""
	### Select only partcicipants that took top $(placement_f) spots
	"""
end

# ╔═╡ 64954f9d-8540-46fb-b9ac-7618f6c683b1
@bind refresh_button Button("Refresh data")

# ╔═╡ 19a275ae-6c7b-4301-b5b5-fac45825e621
begin
	refresh_button
	
	@time rd = riot.Riot.import_all_data(n_days)
	
	md"""
	##### Fetched matches for $(n_days) days
	
	##### Got $(length(rd.participants.PUUID)) participant rows
	"""
end

# ╔═╡ 5bbd2c5f-3a89-419f-8936-f063c853fd43
begin
	all_traits = filter((t)->!startswith(t, "TFTTutorial"), unique(rd.traits.Trait))
	
	md"""
	  ##### Found $(length(all_traits)) total traits
	"""	
end

# ╔═╡ d89ed438-0339-4c06-b5a9-cc5f78f0cc4b
begin
	champ_rarity = unique(select(rd.units, [:CharacterID, :Rarity]))
	champ_cost = Dict(
		r.CharacterID => r.Rarity
		for r in eachrow(champ_rarity)
	)
	"Champ cost table"
end

# ╔═╡ 8a641b43-8ea3-49c6-ae3c-148542beba07
begin
	function rarity_color(rar)
		if rar == 0
			"#213042" #gray
		elseif rar == 1
			"#156831" #green
		elseif rar == 2
			"#12407c" #blue
		elseif rar == 3
			"#893088" #purple
		elseif rar == 5
			"#b89d27" #gold
		end
	end

	function rarity_color_for(id)
		if id in keys(champ_cost)
			rarity_color(champ_cost[id])
		else
			"rgba(255, 255, 255, 0)"
		end
	end

	capfirstchars = ["KhaZix", "ChoGath"]

	function mapcharname(s)
		if s in capfirstchars
			uppercasefirst(lowercase(s))
		else
			s
		end
	end

	itemmappings = Dict(
		"Chalice" => "ChaliceofPower",
		"PowerGauntlet" => "HandofJustice",
		"RapidFireCannon" => "RapidFirecannon",
		"Shroud" => "ShroudofStillness",		
	)

	function mapitemname(s)
		if s in keys(itemmappings)
			itemmappings[s]
		else
			replace(s, "The" => "the", "Of" => "of")
		end
	end

	function icon_for(s, kind=:champ; set="7")
		if kind == :champ
			"https://rerollcdn.com/characters/Skin/$(set)/$(mapcharname(s)).png"
		elseif kind == :trait
			"https://rerollcdn.com/icons/$(lowercase(s)).png"
		elseif kind == :item
			"https://rerollcdn.com/items/$(mapitemname(s)).png"
		end
	end

	function render_pair_icons(pair)
		kind=:pair
		icons = []
		
		for s in pair				
			img = render_icon(s, :trait)
			push!(icons, img)
		end

		icons
	end

	function render_icon(s, kind=:champ)
		if kind == :pair
			render_pair_icons(s)
		else	
			src = icon_for(s, kind)
			klass = "$(String(kind))_icon icon"
			color = rarity_color_for(s)
			style = "border-color: $color"
				
			@htl("""
			<img class=$(klass) src=$(src) alt=$(s) style=$(style) />
			""")
		end
	end
end

# ╔═╡ 0ae7bdeb-690e-4096-b9f9-13c3a9624ff1
function FancyMultiSelect(options; icon_kind=:champ)
	id = randstring(['0':'9'; 'a':'f'])
	render_id = randstring(['0':'9'; 'a':'f'])
	icons = Dict(o => icon_for(o, icon_kind) for o in options)
	img_class = "$(String(icon_kind))_icon"
	if icon_kind == :champ
	    id = "champion_selector_div"
	end
	opt_colors = Dict(
		o => rarity_color_for(o)
		for o in options
	)
	
	@htl("""
	<div id=$(id)>  
		<div id=$(render_id)></div>

  		<style>
  			.option_link {
  				display: inline-block;
  				margin: 5px;
  				text-decoration: none;
  				vertical-align: middle;
  				width: 40px;
  				height: 40px;
			}	
  
  			.rm_link {}
  
  			.add_link {}
  		</style>
		
		<script>
			console.log(this);
			const selectorDiv = document.getElementById($(id));
			const renderTarget = document.getElementById($(render_id));
			
			selectorDiv.value = selectorDiv.value || [];
			const all_options = $(options);	
  			const icons = $(icons);
			const colors = $(opt_colors);
			
			function render(){
  				const not_selected = all_options.filter((c) => !selectorDiv.value.includes(c));
  
				renderTarget.innerHTML = '';
				renderOpts(selectorDiv.value, "option_link rm_link", rmOption);
				renderTarget.appendChild(document.createElement("hr"));
				renderOpts(not_selected, "option_link add_link", addOption);
			}
			
			function addOption(opt) {
				console.log("Adding", opt);
				selectorDiv.value.push(opt);
				selectorDiv.dispatchEvent(new Event('input'));
				render();
			}
			
			function rmOption(opt) {
				console.log("Removing", opt);
				selectorDiv.value = selectorDiv.value.filter((o) => o != opt);
				selectorDiv.dispatchEvent(new Event('input'));
				render();
			}
			
			function renderOpts(opts, klass, cb) {
				opts.forEach((o) => {
					const a = document.createElement("a");
					a.href="#";
  					a.title = o;
					a.className = klass;
					a.addEventListener("click", (e) => { cb(o); e.preventDefault() });
  					const icon = icons[o];
	                const color = colors[o];
  					if (icon !== undefined) {
  						const img = document.createElement("img");
  						img.src = icon;
  						img.className = "icon " + $(img_class)
  						img.alt = o;
						img.style.borderColor = color;
  						a.appendChild(img);
					}

					renderTarget.appendChild(a);
				})
			}

  			selectorDiv.addOption = addOption;
  			selectorDiv.rmOption = rmOption;
			
			render();
		</script>
	</div>
  """)
end

# ╔═╡ 5260fa13-db26-4379-8df1-dd5bdedd3ff3
function FancyOptionPowerSelector(options)
	return PlutoUI.combine() do Child	
		inputs = [
			md""" $(render_icon(opt, :trait)) $(
				Child(opt, Slider(1:12))
			)"""
			
			for opt in options
		]
		
		md"""
		  ##### Select power levels
		  $(inputs)
		"""
	end
end

# ╔═╡ 2054f69b-07b8-4dc4-91dc-cdfed8481b39
begin
	function viz_freq(coll; limit=10)
		set_default_plot_size(17cm, 1cm*limit)
		
		ft = freqtable(coll)
		df = DataFrame(Label = names(ft)[1], Freq = ft)
		sort!(df, [:Freq], rev=true)
	
		df = first(df, limit)
		sort!(df, [:Freq])
	    plot(df, x=:Freq, y=:Label, Geom.bar(position=:dodge, orientation=:horizontal))
	end

	function viz_freq_simple(coll; limit=10, icon_kind=:champ)		
		ft = freqtable(coll)
		df = DataFrame(Label = names(ft)[1], Freq = ft)
		sort!(df, [:Freq], rev=true)
	
		df = first(df, limit)

		onclick = (s)->""

		if icon_kind == :champ
			onclick = (s)->"document.getElementById('champion_selector_div').addOption('$(s)');"
		end

		base_width = 40
		icon_width = "$(base_width)px"
		if icon_kind == :pair
			iwidth = base_width * length(first(coll))
			icon_width = "$(iwidth)px"
		end

		if nrow(df) > 0
			max_v = maximum(df.Freq)
			inputs = [
				@htl("""
				<div class="centered" style="margin-bottom:10px; cursor: pointer;" onclick=$(onclick(r.Label))>
					$(render_icon(r.Label, icon_kind))
				</div>
				<div class="centered" style="margin-bottom:10px;">
					<progress value=$(r.Freq) max=$(max_v) style='width: 100%' />
				</div>
				""")
				for r in eachrow(df)
			]
	
			@htl("""
				<div style="display: grid; grid-template-columns: $(icon_width) auto;">
					$(inputs)
				</div>
				<hr/>
			""")
		end
	end
end

# ╔═╡ 3d0fcdac-8a4b-489e-8940-215c4e0b4c26
function render_champ_items(c)
	items = filter((r)->r.CharacterID == c, rd.items)
	graph = viz_freq_simple(items.Item; limit = 9, icon_kind = :item)
	
	md"""
	### $(render_icon(c)) $(c)
	
	$(graph)
	"""
end

# ╔═╡ 744599ac-f0b4-404e-8aa7-890196210dcc
begin
	comp_limit_f = @bind comp_graph_limit Slider(1:5; default = 2)
	md"""
	### Select $(comp_limit_f) traits for comp graph
	"""
end

# ╔═╡ 26e9433d-c599-4a83-8a8a-49cc7b31c0b1
begin
	sorted_traits = sort(rd.traits, :NumUnits, rev=true)
	gtdf = groupby(sorted_traits, [:MatchID, :PUUID])

	comp_pairs = []

	for g in gtdf 
		pair = first(g, comp_graph_limit)
		push!(comp_pairs, pair.Trait)
	end

	comp_graph = viz_freq_simple(comp_pairs; icon_kind=:pair)

	md"""
	## Popular comps
	$(comp_graph)
	"""
end

# ╔═╡ 14fb0cd0-8a18-458a-b1f9-992ef46108f2
begin
	trait_sel = @bind current_traits FancyMultiSelect(sort(all_traits); icon_kind=:trait)

	md"""
	## Select your traits:
	$(trait_sel)
	"""
end

# ╔═╡ 9e4f28be-a462-4580-87da-5b9ef34dcd93
if current_traits !== missing
	@bind trait_power FancyOptionPowerSelector(current_traits)
else
	waveform
end

# ╔═╡ 7f472eeb-e3d2-4174-b19a-b10e3904e96e
if trait_power !== missing
	trait_power_labels = [
		md"### $(render_icon(String(t), :trait)) $(p)"
		for (t, p) in Dict(pairs(trait_power))
	]
	md"""
	  ##### Looking for comp with following traits
	  $(trait_power_labels)
	"""
else
	waveform
end

# ╔═╡ 4f0c62ad-90e6-4055-92fd-51ef2aa85e0e
if trait_power !== missing &&
	rd !== missing
	
	cdf = innerjoin(rd.units, rd.traits, rd.participants, on = [:MatchID, :PUUID])
	trait_filter = Dict(String(k) => v for (k, v) in Dict(pairs(trait_power)))
	all_champs = unique(rd.units.CharacterID)
	if length(trait_filter) > 0
		filtered_df = filter((r)-> 
								r.Trait in keys(trait_filter) &&
								r.NumUnits >= trait_filter[r.Trait],
								cdf)
		all_champs = unique(filtered_df.CharacterID)
	end

	md"""
	  ##### Found $(length(all_champs)) total champions
	"""
else
	waveform
end

# ╔═╡ 45130875-f0a3-4c33-93b2-fe93d8397c2e
begin
	champ_sel = @bind current_champs FancyMultiSelect(sort(all_champs))
	limit_slider = @bind graph_h_limit Slider(5:100;default=10)

	md"""
	## Select your champions:
	$(champ_sel)

	## Limit graph output: 
	$(limit_slider)
	"""
end

# ╔═╡ 1771bc71-8d82-424d-8406-bf4d2e57d611
if current_champs !== missing
	df = innerjoin(rd.units, rd.traits, rd.participants, on = [:MatchID, :PUUID])
	df = filter(r->r.Placement <= placement_cutoff, df)
	if length(trait_filter) > 0
		df = filter((r)-> 
						r.Trait in keys(trait_filter) &&
						r.NumUnits >= trait_filter[r.Trait],
						df)
	end
	
	groups = groupby(df, [:MatchID, :PUUID])
	groups = filter(g->issubset(current_champs, g.CharacterID), groups)
	other_champs = []
	for g in groups
		for c in g.CharacterID
			if !(c in current_champs)
				push!(other_champs, c)
			end
		end
	end

    champ_plot = viz_freq_simple(other_champs; limit = graph_h_limit)
	
	md"""
	#### Selected champs:
	$(map(render_icon, current_champs))
	
	### Popular champion choices:
	$(champ_plot)
	"""
else
	waveform
end

# ╔═╡ 61fdd2b2-aec1-4249-93c9-88fc3a5b9fa3
if current_champs !== missing
	renders = [
		render_champ_items(c)
		for c in current_champs
	]

	md"""
	  ## Popular items for selected champions:
	
	  $(renders)
	"""
else
	waveform
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
FreqTables = "da1fdf0e-e0ff-5433-a45f-9bb5ff651cb1"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
DataFrames = "~1.3.4"
FreqTables = "~0.4.5"
HypertextLiteral = "~0.9.4"
PlutoUI = "~0.7.39"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "5f5a975d996026a8dd877c35fe26a7b8179c02ba"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.6"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "0f4e115f6f34bbe43c19751c90a38b2f380637b9"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.3"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "87e84b2293559571802f97dd9c94cfd6be52c5e5"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.44.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "daa21eb85147f72e41f6352a57fccea377e310a9"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.4"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreqTables]]
deps = ["CategoricalArrays", "Missings", "NamedArrays", "Tables"]
git-tree-sha1 = "488ad2dab30fd2727ee65451f790c81ed454666d"
uuid = "da1fdf0e-e0ff-5433-a45f-9bb5ff651cb1"
version = "0.4.5"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NamedArrays]]
deps = ["Combinatorics", "DataStructures", "DelimitedFiles", "InvertedIndices", "LinearAlgebra", "Random", "Requires", "SparseArrays", "Statistics"]
git-tree-sha1 = "2fd5787125d1a93fbe30961bd841707b8a80d75b"
uuid = "86f7a689-2022-50b4-a561-43c23ac3c673"
version = "0.9.6"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "1285416549ccfcdf0c50d4997a94331e88d68413"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.3.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "8d1f54886b9037091edf146b517989fc4a09efec"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.39"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─7d3b92bc-e204-11ec-1da7-f5f3d36f2b35
# ╟─7bc24ef4-e910-4651-8ca4-2c012b670161
# ╟─861f00e8-c967-4281-9b12-0b510082580d
# ╟─8a641b43-8ea3-49c6-ae3c-148542beba07
# ╟─0ae7bdeb-690e-4096-b9f9-13c3a9624ff1
# ╟─5260fa13-db26-4379-8df1-dd5bdedd3ff3
# ╟─2054f69b-07b8-4dc4-91dc-cdfed8481b39
# ╟─3d0fcdac-8a4b-489e-8940-215c4e0b4c26
# ╟─3731faa2-4d9f-4d98-b095-781a7c2464c1
# ╟─3830b19e-3365-4f30-9e93-3304fe5a345b
# ╟─80a9b48a-ff99-449c-ba6e-309ced8e5726
# ╟─64954f9d-8540-46fb-b9ac-7618f6c683b1
# ╟─19a275ae-6c7b-4301-b5b5-fac45825e621
# ╟─5bbd2c5f-3a89-419f-8936-f063c853fd43
# ╟─d89ed438-0339-4c06-b5a9-cc5f78f0cc4b
# ╟─744599ac-f0b4-404e-8aa7-890196210dcc
# ╟─26e9433d-c599-4a83-8a8a-49cc7b31c0b1
# ╟─14fb0cd0-8a18-458a-b1f9-992ef46108f2
# ╟─9e4f28be-a462-4580-87da-5b9ef34dcd93
# ╟─7f472eeb-e3d2-4174-b19a-b10e3904e96e
# ╟─4f0c62ad-90e6-4055-92fd-51ef2aa85e0e
# ╟─45130875-f0a3-4c33-93b2-fe93d8397c2e
# ╟─1771bc71-8d82-424d-8406-bf4d2e57d611
# ╟─61fdd2b2-aec1-4249-93c9-88fc3a5b9fa3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
