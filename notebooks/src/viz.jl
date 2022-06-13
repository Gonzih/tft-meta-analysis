module Viz

using FreqTables
using DataFrames
using HypertextLiteral
using Random
using PlutoUI
using Markdown
using InteractiveUtils

function rarity_color(rar)
    if rar == 0
        "#213042" #gray
    elseif rar == 1
        "#156831" #green
    elseif rar == 2
        "#12407c" #blue
    elseif rar == 3 || rar == 4
        "#893088" #purple
    elseif rar == 5 || rar == 6
        "#b89d27" #gold
    end
end

function rarity_color_for(id, champ_cost = Dict(), kind = :champ)
    if id in keys(champ_cost) && kind == :champ
        rarity_color(champ_cost[id])
    else
        "rgba(255, 255, 255, 0)"
    end
end

capfirstchars = ["KhaZix", "ChoGath"]

charmappings = Dict(
    "DragonGreen" => "ShiOhYu",
    "DragonPurple" => "Syfen",
    "DragonGold" => "Idas",
    "DragonBlue" => "Daeja",
    "TrainerDragon" => "Nomsy",
)

function mapcharname(s)
    if s in capfirstchars
        uppercasefirst(lowercase(s))
    elseif s in keys(charmappings)
        charmappings[s]
    else
        s
    end
end

itemmappings = Dict(
    "Chalice" => "ChaliceofPower",
    "PowerGauntlet" => "HandofJustice",
    "RapidFireCannon" => "RapidFirecannon",
    "Shroud" => "ShroudofStillness",
    "SeraphsEmbrace" => "BlueBuff",
    "GuardianAngel" => "TitansResolve",
    "TitanicHydra" => "ZzRotPortal",
    "ForceOfNature" => "TacticiansCrown",
    "RedBuff" => "SunfireCape",
    "MadredsBloodrazor" => "GiantSlayer",
    "UnstableConcoction" => "BansheesClaw", # not sure about this one, might be the edge of night
)

function mapitemname(s)
    if s in keys(itemmappings)
        itemmappings[s]
    else
        replace(s, "The" => "the", "Of" => "of")
    end
end

traitmappings = Dict(
    "spellthief" => "spell-thief",
)

function maptraitname(s)
    s = lowercase(s)

    if s in keys(traitmappings)
        traitmappings[s]
    else
        s
    end
end

function icon_for(s, kind = :champ; set = "7")
    if kind == :champ
        "https://rerollcdn.com/characters/Skin/$(set)/$(mapcharname(s)).png"
    elseif kind == :trait
        "https://rerollcdn.com/icons/$(maptraitname(s)).png"
    elseif kind == :item
        "https://rerollcdn.com/items/$(mapitemname(s)).png"
    end
end

function render_pair_icons(pair)
    kind = :pair
    icons = []

    for s in pair
        img = render_icon(s, :trait)
        push!(icons, img)
    end

    icons
end

function render_icon(s, kind = :champ, champ_cost_dict = Dict())
    if kind == :pair
        render_pair_icons(s)
    else
        src = icon_for(s, kind)
        klass = "$(String(kind))_icon icon"
        color = rarity_color_for(s, champ_cost_dict)
        style = "border-color: $color"

        @htl("""
        <img class=$(klass) src=$(src) alt=$(s) style=$(style) />
        """)
    end
end

function FancyMultiSelect(options; icon_kind = :champ, champ_cost_dict = Dict())
    id = randstring(['0':'9'; 'a':'f'])
    render_id = randstring(['0':'9'; 'a':'f'])
    icons = Dict(o => icon_for(o, icon_kind) for o in options)
    img_class = "$(String(icon_kind))_icon"
    if icon_kind == :champ
        id = "champion_selector_div"
    end
    opt_colors = Dict(
        o => rarity_color_for(o, champ_cost_dict, icon_kind)
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

function freq(coll; limit = 10)
    set_default_plot_size(17cm, 1cm * limit)

    ft = freqtable(coll)
    df = DataFrame(Label = names(ft)[1], Freq = ft)
    sort!(df, [:Freq], rev = true)

    df = first(df, limit)
    sort!(df, [:Freq])
    plot(df, x = :Freq, y = :Label, Geom.bar(position = :dodge, orientation = :horizontal))
end

function freq_simple(coll; limit = 10, icon_kind = :champ, champ_cost_dict = Dict())
    ft = freqtable(coll)
    df = DataFrame(Label = names(ft)[1], Freq = ft)
    sort!(df, [:Freq], rev = true)

    df = first(df, limit)

    onclick = (s) -> ""

    if icon_kind == :champ
        onclick = (s) -> "document.getElementById('champion_selector_div').addOption('$(s)');"
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

function render_champ_items(c, items_df)
    items = filter((r) -> r.CharacterID == c, items_df)
    graph = freq_simple(items.Item; limit = 9, icon_kind = :item)

    md"""
    ### $(render_icon(c)) $(c)

    $(graph)
    """
end

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

end
