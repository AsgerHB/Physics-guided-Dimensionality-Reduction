### A Pluto.jl notebook ###
# v0.19.36

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

# ╔═╡ 9c8abfbc-a5f0-11ec-3a9b-9bfd0b447638
begin
	using Pkg
	Pkg.activate(".")
	Pkg.develop("GridShielding")
	using GridShielding
	using Plots
	using PlutoUI
	using Measures
	using Unzip
	include("Shared Code/FlatUI.jl")
end

# ╔═╡ c663a860-4562-4de0-9b08-edc041cde9e6
md"""
# Preamble
"""

# ╔═╡ bffbac67-8a3b-4155-a665-0c39f93d3dd7
TableOfContents()

# ╔═╡ 6fee7dcf-a0ee-431a-a5b7-d31c54ffa1a6
BB = GridShielding.BB

# ╔═╡ da2f3b65-c072-4d54-99b5-83cb9d070d85
call(f) = f()

# ╔═╡ 61fa5c6f-2f91-4429-a479-10266f6332c8
md"""
# A New State Space

$(E_{mek},~~ \Delta E_{mek},~~ 𝟙(v > 0))$

## $E_{mek}$, Mechanical Energy

$E_{mek} = E_{pot} = E_{kin}$

$E_{pot} = m g p$

$E_{kin} = {1 \over 2} m v^2$
"""

# ╔═╡ f93a65f3-9bdf-493b-994c-a26f34818a96
e_pot(g, p) = abs(g)*p

# ╔═╡ a3af719b-3b92-4c39-a95e-478d5b3179a2
e_kin(g, v) = 0.5*v^2

# ╔═╡ b775a061-3279-4121-806c-e99d211c36b0
e_mek(g, v, p) = e_kin(g, v) + e_pot(g, p)

# ╔═╡ 3544f929-e518-485f-bdec-eaf1506f3226
md"""
`v_0 =` $(@bind v_0 NumberField(-13:1:13, default = 4))
`p_0 =` $(@bind p_0 NumberField(0:1:13, default = 4))

"""

# ╔═╡ 67d30df1-b60a-4835-a331-94957908ae4a
const m = BB.bbmechanics

# ╔═╡ 19281cd7-e79d-4535-9c53-9e9de9882eb0
const g = m.g

# ╔═╡ 0ad2d3c9-3a81-4582-b7dc-52225e0c99e9
velocity_from_e_kin(e) = sqrt(2*e)

# ╔═╡ 72d3376b-c91a-43c6-b237-53e83970fd4f
velocity_from_e_kin(e_kin(g, 4))

# ╔═╡ dc918da4-5ab4-4795-a220-67ffbccb97d1
position_from_e_pot(e) = e/g

# ╔═╡ 5a251063-64e8-4ced-8e28-34cb4812f931
position_from_e_pot(e_mek(g, 0, 4))

# ╔═╡ 52b72834-46ea-44de-8b44-013c4574f2d2
vs, ps, ts = BB.simulate_sequence(m, (0, 2), (_...) -> "nohit", 8)

# ╔═╡ b60a9495-7d59-4faa-a399-ac83a83d934d
function draw_function(policy::Function, x_min, x_max, y_min, y_max, G; plotargs...)
	size_x, size_y = Int((x_max - x_min)/G), Int((y_max - y_min)/G)
	matrix = Matrix(undef, size_x, size_y)
	for i in 1:size_x
		for j in 1:size_y
			x, y = i*G - G + x_min, j*G - G + y_min

			matrix[i, j] = policy([x, y])
		end
	end
	x_tics = G+x_min:G:x_max
	y_tics = G+y_min:G:y_max
	middle_x, middle_y = [(x_max - x_min)/2 + x_min], [(y_max - y_min)/2 + y_min]
	plot(;plotargs...)
	heatmap!(x_tics, y_tics, transpose(matrix);
			plotargs...)
end

# ╔═╡ c1a7ffdd-767d-418d-96af-f13b357e980e
@bind gradient Select([[:black, :deepskyblue, :white], :heat, :matter, :curl, :dense, :phase, :algae])

# ╔═╡ cad96c13-e9fa-45ae-b046-f976ae2ee901
p2 = draw_function((vp) -> e_mek(g, vp...), -15, 15, 0, 10, 0.05,
	color=cgrad(gradient, 10, categorical=false),
	xlabel="Velocity (m/s)",
	ylabel="Position (m)",
	colorbar_title="Mechanical Energy (J)")

# ╔═╡ 490abcb1-80ea-4bbe-9b4f-b8133d22d9dd
p1 = draw_function((vp) -> e_mek(g, vp...), -15, 15, 0, 10, 0.05,
	color=cgrad(gradient, 10, categorical=true),
	xlabel="Velocity (m/s)",
	ylabel="Position (m)",
	colorbar_title="Mechanical Energy (J)")

# ╔═╡ 00c40a94-4165-4fec-b7f4-edd531b3044c
p3 = draw_function((vp) -> e_mek(g, vp...), -15, 15, 0, 10, 0.05,
		color=cgrad(gradient, 10, categorical=true))

# ╔═╡ 6b442e46-afc3-4b01-9205-7826f192f5c8
 p4 = begin 
	 draw_function((vp) -> e_mek(g, vp...), -15, 15, 0, 10, 0.05,
		color=cgrad(gradient, 10, categorical=true),
		xlabel="Velocity (m/s)",
		ylabel="Position (m)",
		colorbar_title="Mechanical Energy (J)");
	 plot!(Shape([(-4, 4), (-4, 10), (15, 10), (15, 4)]), alpha=0.3, color=colors.EMERALD, label="Possible to hit")
 end

# ╔═╡ 2556f5de-5e22-4f88-b4bf-f3f4c87d06be
p1, p2, p3, p4; @bind ExportButton CounterButton("Export")

# ╔═╡ 3cfe65d2-7f6b-47c9-9c5f-ebc09229a2e6
if ExportButton > 0 let
	png(p1, "Graphics/BB Mechanical Energy Grouped.png")
	png(p2, "Graphics/BB Mechanical Energy Smooth.png")
	png(p3, "Graphics/BB Mechanical Energy Grouped - No Axis Labels.png")
	png(p4, "Graphics/Possible to Hit.png")
	png(p5, "Graphics/Energy Gain on Swing.png")
end end

# ╔═╡ b527f190-ff38-48d3-97ae-aeeed8fdd273
md"""
## How traces look in the new projection
"""

# ╔═╡ ff60b015-12cf-478b-9a60-93a9b93d0f5f
trace = BB.simulate_sequence(m, (0, 10), (_...) -> "nohit", 20)

# ╔═╡ 87651747-c606-4f15-b335-649492faedd9
plot(); BB.animate_trace(trace...)

# ╔═╡ aad4b9e6-2fbb-46a9-9311-f9e534a17002
md"""
# Creating a Grid based on new space
"""

# ╔═╡ f363e7ad-ad45-4fca-83c3-7b04ffdf48eb
bbshieldlabels = 	[
	"{$(join(int_to_actions(BB.Action, i), ", "))}"
	for i in 0:3]

# ╔═╡ 8f0f7850-c149-4735-a2d5-f58182251d34
bbshieldcolors = [colors.WET_ASPHALT, colors.AMETHYST, colors.SUNFLOWER, colors.CLOUDS];

# ╔═╡ 5c3ed2b7-81c0-42e5-b157-d65e25537791
vp_bounds = Bounds((-20, 0), (20, 13))

# ╔═╡ 78cb48d3-bedf-48e9-9479-8c71bcc10f6f
function π(v, p) 
	
	return e_mek(g, v, p), v, (p > 4 ? 1 : 0)
	
end

# ╔═╡ d30c6363-75e6-42f8-b3a0-4a032df063ef
begin
	π_xlabel = "\$E_{mek}\$"
	π_ylabel = "v"
	π_zlabel = "p > 4"
end

# ╔═╡ d0dd5ad2-97b6-4d7a-a97b-cb33b29230e6
function animate_trace(trace, shield::Union{Nothing,Grid}=nothing)
	vs, ps, ts = trace
	e_kins = [e_kin(g, v) for v in vs]
	e_pots = [e_pot(g, p) for (v, p) in zip(vs, ps)]
	e_meks = [e_pot(g, p) + e_kin(g, v) for (v, p) in zip(vs, ps)]
	πs = [π(v, p) for (v, p) in zip(vs, ps)]
	layout = 2
	
	x1, y1 = [s[1] for s in πs], [s[2] for s in πs]
	x1label=π_xlabel
	y1label=π_ylabel

	if isnothing(shield)
		x1lims=(minimum(x1) - 3, maximum(x1) + 3)
		y1lims=(minimum(y1) - 3, maximum(y1) + 3)
	else
		x1lims=(shield.bounds.lower[1], shield.bounds.upper[1])
		y1lims=(shield.bounds.lower[2], shield.bounds.upper[2])
	end
	
	x2, y2 = ts, ps
	x2label="t"
	y2label="p"
	x2lims=(minimum(x2) - 3, maximum(x2) + 3)
	y2lims=(minimum(y2) - 0, maximum(y2) + 3)

	animation = @animate for (i, _) in enumerate(ts)
		
		p1 = if isnothing(shield)
			plot()
		else
			p1 = draw(shield, πs[i][3] == 1 ? [:, :, 2] : [:, :, 1], 
				colors=bbshieldcolors, color_labels=bbshieldlabels)
		end
		
		plot!(x1[1:i], y1[1:i],
			xlims=x1lims,
			ylims=y1lims,
			xlabel=x1label,
			ylabel=y1label,
			color=colors.WET_ASPHALT,
			linewidth=2,
			markersize=2,
			markeralpha=1,
			markershape=:circle)
		
		scatter!([x1[i]], [y1[i]], marker=(3, :circle, :red))
		
		
		p2 = plot(ts[1:i], ps[1:i],
			xlims=x2lims,
			ylims=y2lims,
			xlabel=x2label,
			ylabel=y2label,
			color=colors.WET_ASPHALT,
			linewidth=2,
			markersize=2,
			markeralpha=1,
			markershape=:circle)

		hline!([4], label=nothing, color=colors.WET_ASPHALT)
		scatter!([x2[i]], [y2[i]], marker=(3, :circle, :red))
		
		plot(p1, p2, 
			layout=layout, 
			size=(800, 400), 
			legend=nothing)
	end
	
	gif(animation, joinpath(tempdir(), "trace.gif"), fps=10, show_msg=false)
end

# ╔═╡ 937afb55-7775-482d-8674-260c8de29614
animate_trace(trace)

# ╔═╡ 2408a96c-8634-4fe9-91aa-af32ac2c7dec
const π_bounds = let
	e_mek_upper = e_mek(g, vp_bounds.upper...)
	v_lower, v_upper = vp_bounds.lower[1], vp_bounds.upper[1]
	
	Bounds((0., v_lower, 0.), ceil.((e_mek_upper, v_upper, 2.0)))
end

# ╔═╡ 898fcb77-2f6d-42b9-93c7-dce396664174
md"""
## Reachability Function
"""

# ╔═╡ 206a65db-e953-4216-9689-31966739c88d
const samples_per_random_axis = [1]

# ╔═╡ 6327ed76-cf69-4389-8ce2-e0e9c42eb11f
md"""
### Brute-force sampling

Solving these constraints can be quite tedious so what I do instead is just iterate through samplese that cover the whole state space and check for every sample if it is a member of the π-partition. Horribly inefficient, but it works for this example.
"""

# ╔═╡ 01190c0f-b8bb-403f-8eed-57d683ad302a
# Number of samples per unit
const global_sampling_resolution = 10

# ╔═╡ c98583c9-3105-46b3-80b4-06b84d6e1db6
global_supporting_points::Vector{Tuple{Float64, Float64}} = SupportingPoints([
		(u - l)*global_sampling_resolution
		for (l, u) in zip(vp_bounds.lower, vp_bounds.upper)
	], 
	vp_bounds) |> collect;

# ╔═╡ f9fbc97a-3b7d-45f4-a784-45d2cf515fa1
scatter(global_supporting_points,
	marker=(2, :red, :circle),
	markerstrokewidth=0,
	xlabel="v",
	ylabel="p",
	label="global supporting points")

# ╔═╡ f351c1ed-89d0-495c-8720-7f1ffa9ddd93
begin
	# Brute-force approach to sample generation
	# by checking membership of every single sample in the state space
	# for some resolution of samples
	struct BruteForceSampler
		partition::Partition
		points::Vector{Tuple{Float64, Float64}}
	end

	
	Base.IteratorSize(::BruteForceSampler) = Base.SizeUnknown()
	
	Base.iterate(sampler::BruteForceSampler) = begin
		Base.iterate(sampler, 1)
	end

	Base.iterate(sampler::BruteForceSampler, i::Int64) = begin
		l = length(sampler.points)
		while π(sampler.points[i]...) ∉ sampler.partition && i < l
			i += 1
		end
		if i == l
			nothing
		else
			(sampler.points[i], i + 1)
		end
	end
end

# ╔═╡ f4364c08-d09b-4dcc-89ea-e3a58490d901
function reachability_function(partition, action)::Vector{Vector{Int64}}
	result = Vector{Int64}[]
	grid = partition.grid
	for point::Tuple{Float64, Float64} in 
			BruteForceSampler(partition, global_supporting_points)

		for r in SupportingPoints(samples_per_random_axis, Bounds((-1,), (1,)))
			point′ = BB.simulate_point(m, point, r, action)
			π_point′ = π(point′...)
			if π_point′ ∉ grid
				continue
			end
			partition′ = box(grid, π_point′)
			if partition′.indices ∈ result
				continue
			end
			push!(result, partition′.indices)
		end
	end
	result
end

# ╔═╡ 94ced2a5-7ad8-49e3-b1d1-e1d5b8ee9868
md"""
## Synthesize a Shield
"""

# ╔═╡ 7dad96ac-3c70-4b75-86a1-3ab374d631fa
@bind max_steps NumberField(0:1000, default=1000)

# ╔═╡ 3f4d6c5b-b4a9-42c2-909e-569061590af7
@bind show_point CheckBox()

# ╔═╡ fd928206-accf-44fc-8762-599fe34c26b6
@bind action Select(BB.Action |> instances |> collect, default="nohit")

# ╔═╡ 7802329e-9ef1-40a5-8d5f-79010fa6ac1f
BB.simulate_point(m, (v_0, p_0), action)

# ╔═╡ 22d05a23-bcad-4281-8303-5082a3d8e785
# ╠═╡ disabled = true
#=╠═╡
@bind v NumberField(-15:0.2:15)
  ╠═╡ =#

# ╔═╡ 2a4c1d40-bd6d-4e83-94d8-c6a3cfa8aee0
# ╠═╡ disabled = true
#=╠═╡
@bind p NumberField(0:0.1:8)
  ╠═╡ =#

# ╔═╡ 080a4374-104e-4c30-b946-313475fb0c11
any_action, no_action = actions_to_int([BB.hit BB.nohit]), actions_to_int([])

# ╔═╡ 26092473-69d3-4777-9890-48fa928ccc94
function initial_value_of_vp_partition(bounds::Bounds)
	vl, pl = bounds.lower
	vu, pu = bounds.upper

	if e_mek(g, vl, pl) < 0.5 || e_mek(g, vu, pl) < 0.5
		no_action
	else
		any_action
	end
end

# ╔═╡ fc8619b5-8dbc-47b3-b66e-24ceeeb45f7f
begin
	vp_grid = Grid(1, vp_bounds)
	initialize!(vp_grid, initial_value_of_vp_partition)
	vp_grid
end

# ╔═╡ 814e17fe-4824-410d-a46f-da73729d6e8c
function initial_value_of_π_partition(bounds::Bounds)::Int64
	e_mek_lower, _, _ = bounds.lower
	if e_mek_lower < 0.5
		no_action
	else
		any_action
	end
end

# ╔═╡ 3e00e758-2e2e-42da-9152-fff188f75875
begin
	π_grid = Grid([4, 2, 1], π_bounds)
	initialize!(π_grid, initial_value_of_π_partition)
	π_grid
end

# ╔═╡ cc239362-e3a9-4e7b-bef7-737233e2d338
size(π_grid), length(π_grid)

# ╔═╡ 670639a2-dc12-45af-bb38-5d197ff41fd4
let	
	p1 = draw(π_grid, [:, :, 2],
		title=π_zlabel,
		xlabel=π_xlabel,
		ylabel=π_ylabel,
		colors=[:white, :white], 
		#color_labels=bbshieldlabels,
		margin=4mm,
		show_grid=true,
		legend=:topright)

	p2 = draw(π_grid, [:, :, 1],
		title="not $π_zlabel",
		xlabel=π_xlabel,
		ylabel=π_ylabel,
		colors=[:white, :white], 
		#color_labels=bbshieldlabels,
		margin=4mm,
		show_grid=true,
		legend=:topright)

	plot(p1, p2, size=(600, 300))
end

# ╔═╡ 443301cb-ef1c-40b3-a552-f86e46e0cbe8
let
	valid_partitions = let
		result = Partition[]
		for partition in π_grid
			points = BruteForceSampler(partition, global_supporting_points) |> collect
			if length(points) > 0
				push!(result, partition)
			end
		end
		result
	end;
	
	# This is the plot of reachable partitions. It's super slow.
	p1 = plot([], 
		title=π_zlabel,
		seriestype=:shape, 
		color=colors.PETER_RIVER, 
		xlabel=π_xlabel,
		ylabel=π_ylabel,
		label=nothing)
	
	plot!(π_bounds, color=:white, linecolor=:white, label=nothing)

	for partition in valid_partitions
		bounds = Bounds(partition)
		if bounds.lower[3] == 0 continue end
		plot!(bounds, color=colors.PETER_RIVER, label=nothing, lw=1)
	end
	plot!(legend=:bottomright)

	p2 = plot([], 
		seriestype=:shape, 
		title="not $π_zlabel",
		color=colors.PETER_RIVER, 
		xlabel=π_xlabel,
		ylabel=π_ylabel,
		label="Ball can actually have this state")

	
	plot!(π_bounds, color=:white, linecolor=:white, label=nothing)

	for partition in valid_partitions
		bounds = Bounds(partition)
		if bounds.lower[3] == 1 continue end
		plot!(bounds, color=colors.PETER_RIVER, label=nothing, lw=1)
	end
	plot!(legend=:bottomright)

	plot(p1, p2, size=(800, 400))
end

# ╔═╡ 77750ddb-f774-4c95-8963-a4fd45806bb6
π; π_grid; @bind do_it_button CounterButton("Do it")

# ╔═╡ e762cebe-cea0-48ea-952b-55d14fbba5bb
if do_it_button >= 0
	reachability_function_precomputed = 
		get_transitions(reachability_function, BB.Action, π_grid);
end

# ╔═╡ af696d4b-aa09-4339-b471-d9c91f065364
shield, max_steps_reached = make_shield(reachability_function_precomputed, BB.Action, π_grid; max_steps)

# ╔═╡ a3e566e8-6b31-4d07-a2b9-b3b90f178d63
Bounds(box(shield, π(7, 0)))

# ╔═╡ 24350838-772a-4357-b4fd-5275d6a70393
length(π_grid)

# ╔═╡ e494556c-1106-49ce-85b4-729136b9b0b3
md"""
## Apply the shield
"""

# ╔═╡ efef17e1-8cd7-4d5b-a805-3d4a7345cf9d
function apply_shield(shield::Grid, policy)
    return (s) -> begin
		a = policy(s)
		if π(s...) ∉ shield
			return a
		end
        allowed = int_to_actions(BB.Action, get_value(box(shield, π(s...))))
        if a ∈ allowed
            return a
        elseif length(allowed) > 0
			a′ = rand(allowed)
            return a′
        else
            return a
        end
    end
end

# ╔═╡ f5bd346f-ba38-42c5-8920-7ec127f8c547
random(s...) = if (rand(1:10) == 1) BB.hit else BB.nohit end

# ╔═╡ 087cbfb4-9f42-4f9a-85cd-e92ff2004cc8
shielded_random = apply_shield(shield, random)

# ╔═╡ 76af8821-a3ae-41ce-9859-363f5ef4711c
function check_safety(mechanics, policy, duration; runs=1000)
	t_hit, g, β1, ϵ1, β2, ϵ2, v_hit, p_hit  = mechanics
	deaths = 0
	example_trace = nothing
	for run in 1:runs
		trace = BB.simulate_sequence(m, (0, 10), policy, duration)
		for (v, p) in zip(trace...)
			if abs(v) < 1 && p == 0
				deaths += 1
				example_trace = trace
				break
			end
		end
		example_trace = something(example_trace, trace)
	end
	deaths, example_trace
end

# ╔═╡ 05b5e4d4-9bea-49b5-ae51-0daa2fb8478d
runs = 1000

# ╔═╡ b2a050b0-2548-4a34-80ae-89f3a0bcb056
deaths, shielded_trace = check_safety(m, shielded_random, 120; runs)

# ╔═╡ 8790b998-d96e-4437-b9bb-d77571d4bd1b
@bind i NumberField(1:length(shielded_trace[1]), default=21)

# ╔═╡ 60401048-7e4a-45c8-a0aa-4fb9338714ab
v = shielded_trace[1][i]

# ╔═╡ a31a8a05-c145-43a9-b844-ccfaf9f49645
p = shielded_trace[2][i]

# ╔═╡ 1f1c79cb-d4d4-4e1b-9a34-b958ed864a7d
let
	p1  = plot(π_grid.bounds,
		color=:white,
		line=nothing,
		label=nothing,
		legend=:outertop,
		xlabel="\$E_{mek}\$",
		ylabel="v",)

	π_point = π(v, p)

	π_partition = box(π_grid, π_point)
	bounds = Bounds(π_partition)
	bounds = Bounds(bounds.lower[1:2], bounds.upper[1:2])

	plot!(bounds, 
		linewidth=0,
		color=:red, 
		label="partition")

	scatter!([π_point[1]], [π_point[2]], 
		title=π_point[3] == 1 ? π_zlabel : "not $π_zlabel",
		marker=(4, :green, :circle),
		markerstrokewidth=1,
		label="π(v, p)")
	
	p2 = plot(vp_grid.bounds,
		color=:white,
		line=nothing,
		label=nothing,
		legend=:outertop,
		xlabel="v",
		ylabel="p")
	
	π_partition = box(π_grid, π(v, p))
	sp = global_supporting_points
		
	sp = BruteForceSampler(box(π_grid, π(v, p)), global_supporting_points) |> collect |> unzip
	
	scatter!(sp, 
		marker=(2, :red, :circle),
		markerstrokewidth=0,
		label="Element of partition")
	
	scatter!([v], [p], 
		label="(v,p)",
		marker=(4, :green, :circle),
		markerstrokewidth=1,)

	plot(p1, p2, size=(800, 400), margin=3mm)
end

# ╔═╡ 021e2fb4-1760-4421-916b-fb2ef306cb13
let
	
	partition = box(shield, π(v, p))

	slice::Vector{Any} = partition.indices
	slice[1] = slice[2] = Colon()
	
	p1 = draw(shield, [:, :, 2],
		title=π_zlabel,
		xlabel=π_xlabel,
		ylabel=π_ylabel,
		colors=bbshieldcolors, 
		color_labels=bbshieldlabels,
		legend=nothing)

	p2 = draw(shield, [:, :, 1],
		title="not $π_zlabel",
		xlabel=π_xlabel,
		ylabel=π_ylabel,
		colors=bbshieldcolors, 
		color_labels=bbshieldlabels,
		legend=:topright)

	if show_point
		## Reachable partitions ##
		π_point = π(v, p)

		reachable = 
			reachability_function_precomputed[action][box(shield, π_point).indices...]

		for indices in reachable
			partition = Partition(shield, indices)
			bounds = Bounds(partition)
			
			if bounds.lower[3] == 1 p1 = plot(p1) else p2 = plot(p2) end
			plot!(bounds,
				color=colors.PETER_RIVER,
				opacity=0.3,
				label=nothing)
		end
		p2 = plot(p2)
		plot!([], seriestype=:shape, 
			color=colors.PETER_RIVER,
			opacity=0.3,
			label="reachable")

		## Barbaric sampling endpoints ##
		points = BruteForceSampler(partition, global_supporting_points)
		left = []
		right = []
		for p in points
			for r in SupportingPoints(samples_per_random_axis, Bounds((0,), (1,)))
				p′ = π(BB.simulate_point(m, p, r, action)...)
				if p′[3] == 1
					push!(left, (p′[1], p′[2]))
				else
					push!(right, (p′[1], p′[2]))
				end
			end
		end
		if length(left) > 0
			p1 = plot(p1)
			
			scatter!(left |> unzip,
				marker=(1, colors.PETER_RIVER, :circle),
				markerstrokewidth=0,
				label="Barbaric sample endpoints")
		end

		if length(right) > 0
			p2 = plot(p2)
			
			scatter!(right |> unzip,
				marker=(1, colors.PETER_RIVER, :circle),
				markerstrokewidth=0,
				label="Barbaric sample endpoints")
		end

		## The actual point ##
		if π(v, p)[3] == 1 p1 = plot(p1) else p2 = plot(p2) end
		
		scatter!([π_point[1]], [π_point[2]],
			marker=(5, colors.EMERALD, :circle),
			markerstrokewidth=0,
			label="(v, p)")
	end

	plot(p1, p2, size=(800, 400))
end

# ╔═╡ 702172e9-59d7-4a77-b663-a89f66132a1f
partition = box(shield, π(v, p))

# ╔═╡ a566b33b-7005-43c3-afce-b8793447f615
let
	draw_function(s -> box(shield, π(s...)) |> get_value, -15, 15, 0, 10, 0.05,
		color=cgrad([colors.WET_ASPHALT, colors.AMETHYST, colors.SUNFLOWER, colors.CLOUDS], 10, categorical=true),
		xlabel="Velocity (m/s)",
		ylabel="Position (m)",
		colorbar=nothing)

	plot!([], seriestype=:shape, color=colors.WET_ASPHALT, label="{}")
	plot!([], seriestype=:shape, color=colors.AMETHYST, label="{hit}")
	plot!([], seriestype=:shape, color=colors.CLOUDS, label="{hit, nohit}")

	if show_point
		points = BruteForceSampler(partition, global_supporting_points)
		barbaric_sample_endpoints = []
		for p in points
			for r in SupportingPoints(samples_per_random_axis, Bounds((0,), (1,)))
				push!(barbaric_sample_endpoints, BB.simulate_point(m, p, r, action))
			end
		end
		scatter!(barbaric_sample_endpoints |> unzip,
			marker=(1, colors.PETER_RIVER, :circle),
			markerstrokewidth=0,
			label="Barbaric sample endpoints")
		
		scatter!([v], [p],
			marker=(5, colors.EMERALD, :circle),
			markerstrokewidth=0,
			label="(v, p)")
	end
	plot!()
end

# ╔═╡ 3961c068-f268-48c5-926c-99cd5c501018
let
	partition = box(π_grid, π(v, p))
	reachability_function(partition, action)
end

# ╔═╡ d4cbae79-3a44-4f1f-839e-3b652bf83a42
shielded_random((v, p))

# ╔═╡ c995f805-fc9b-47c1-bfa9-5dbcc9400806
lazy(_...) = BB.nohit

# ╔═╡ 568bbecc-0726-43d2-ba8e-cc2c468c44b2
shielded_lazy = apply_shield(shield, lazy)

# ╔═╡ 976cb35a-2274-4378-94d7-6276d000c6d8
let
	header = if deaths > 0
		"""!!! danger "Shield unsafe"

		"""
	else
		"""!!! success "Shield safe"

		"""
	end

	Markdown.parse("""$header
		Out of **$runs** runs, **$deaths** of them contained a safety violation.

		`TODO:` Strategy too conservative and considers (v=0, p=7) to be an unsafe state.
	""")
end

# ╔═╡ a6796796-6f4f-470f-ad47-1b655d332905
shielded_trace

# ╔═╡ 4f238ba9-035c-4046-ba45-604bf514be67
begin
	trace_to = findfirst(==((0,0)),  # first unsafe state
		zip(shielded_trace[1], shielded_trace[2]) |> collect)

	trace_to = something(trace_to, length(shielded_trace[1]))
	trace_to = min(trace_to - 100, length(shielded_trace[1]))

	trace_to = something(trace_to, length(shielded_trace[1]))
	trace_from = max(1, trace_to - 250)
end

# ╔═╡ b097e128-a1df-44f0-8fb7-347d9317abfc
animate_trace((shielded_trace[1][trace_from:trace_to],
	shielded_trace[2][trace_from:trace_to],
	shielded_trace[3][trace_from:trace_to]), shield)

# ╔═╡ Cell order:
# ╟─c663a860-4562-4de0-9b08-edc041cde9e6
# ╠═9c8abfbc-a5f0-11ec-3a9b-9bfd0b447638
# ╠═bffbac67-8a3b-4155-a665-0c39f93d3dd7
# ╠═6fee7dcf-a0ee-431a-a5b7-d31c54ffa1a6
# ╠═da2f3b65-c072-4d54-99b5-83cb9d070d85
# ╟─61fa5c6f-2f91-4429-a479-10266f6332c8
# ╠═f93a65f3-9bdf-493b-994c-a26f34818a96
# ╠═a3af719b-3b92-4c39-a95e-478d5b3179a2
# ╠═b775a061-3279-4121-806c-e99d211c36b0
# ╟─3544f929-e518-485f-bdec-eaf1506f3226
# ╠═67d30df1-b60a-4835-a331-94957908ae4a
# ╠═19281cd7-e79d-4535-9c53-9e9de9882eb0
# ╠═7802329e-9ef1-40a5-8d5f-79010fa6ac1f
# ╠═0ad2d3c9-3a81-4582-b7dc-52225e0c99e9
# ╠═72d3376b-c91a-43c6-b237-53e83970fd4f
# ╠═dc918da4-5ab4-4795-a220-67ffbccb97d1
# ╠═5a251063-64e8-4ced-8e28-34cb4812f931
# ╠═52b72834-46ea-44de-8b44-013c4574f2d2
# ╠═b60a9495-7d59-4faa-a399-ac83a83d934d
# ╠═c1a7ffdd-767d-418d-96af-f13b357e980e
# ╟─cad96c13-e9fa-45ae-b046-f976ae2ee901
# ╟─490abcb1-80ea-4bbe-9b4f-b8133d22d9dd
# ╠═2556f5de-5e22-4f88-b4bf-f3f4c87d06be
# ╠═3cfe65d2-7f6b-47c9-9c5f-ebc09229a2e6
# ╠═00c40a94-4165-4fec-b7f4-edd531b3044c
# ╠═6b442e46-afc3-4b01-9205-7826f192f5c8
# ╟─b527f190-ff38-48d3-97ae-aeeed8fdd273
# ╠═ff60b015-12cf-478b-9a60-93a9b93d0f5f
# ╠═d0dd5ad2-97b6-4d7a-a97b-cb33b29230e6
# ╟─87651747-c606-4f15-b335-649492faedd9
# ╟─937afb55-7775-482d-8674-260c8de29614
# ╟─aad4b9e6-2fbb-46a9-9311-f9e534a17002
# ╠═f363e7ad-ad45-4fca-83c3-7b04ffdf48eb
# ╠═8f0f7850-c149-4735-a2d5-f58182251d34
# ╠═26092473-69d3-4777-9890-48fa928ccc94
# ╠═5c3ed2b7-81c0-42e5-b157-d65e25537791
# ╠═fc8619b5-8dbc-47b3-b66e-24ceeeb45f7f
# ╠═78cb48d3-bedf-48e9-9479-8c71bcc10f6f
# ╠═d30c6363-75e6-42f8-b3a0-4a032df063ef
# ╠═2408a96c-8634-4fe9-91aa-af32ac2c7dec
# ╠═814e17fe-4824-410d-a46f-da73729d6e8c
# ╠═3e00e758-2e2e-42da-9152-fff188f75875
# ╠═cc239362-e3a9-4e7b-bef7-737233e2d338
# ╟─670639a2-dc12-45af-bb38-5d197ff41fd4
# ╟─1f1c79cb-d4d4-4e1b-9a34-b958ed864a7d
# ╟─443301cb-ef1c-40b3-a552-f86e46e0cbe8
# ╟─898fcb77-2f6d-42b9-93c7-dce396664174
# ╠═206a65db-e953-4216-9689-31966739c88d
# ╠═f4364c08-d09b-4dcc-89ea-e3a58490d901
# ╟─6327ed76-cf69-4389-8ce2-e0e9c42eb11f
# ╠═01190c0f-b8bb-403f-8eed-57d683ad302a
# ╠═c98583c9-3105-46b3-80b4-06b84d6e1db6
# ╟─f9fbc97a-3b7d-45f4-a784-45d2cf515fa1
# ╠═f351c1ed-89d0-495c-8720-7f1ffa9ddd93
# ╟─94ced2a5-7ad8-49e3-b1d1-e1d5b8ee9868
# ╠═7dad96ac-3c70-4b75-86a1-3ab374d631fa
# ╠═77750ddb-f774-4c95-8963-a4fd45806bb6
# ╠═e762cebe-cea0-48ea-952b-55d14fbba5bb
# ╠═af696d4b-aa09-4339-b471-d9c91f065364
# ╠═24350838-772a-4357-b4fd-5275d6a70393
# ╠═a3e566e8-6b31-4d07-a2b9-b3b90f178d63
# ╠═3f4d6c5b-b4a9-42c2-909e-569061590af7
# ╠═60401048-7e4a-45c8-a0aa-4fb9338714ab
# ╠═a31a8a05-c145-43a9-b844-ccfaf9f49645
# ╠═8790b998-d96e-4437-b9bb-d77571d4bd1b
# ╟─021e2fb4-1760-4421-916b-fb2ef306cb13
# ╠═a566b33b-7005-43c3-afce-b8793447f615
# ╠═702172e9-59d7-4a77-b663-a89f66132a1f
# ╠═fd928206-accf-44fc-8762-599fe34c26b6
# ╠═22d05a23-bcad-4281-8303-5082a3d8e785
# ╠═2a4c1d40-bd6d-4e83-94d8-c6a3cfa8aee0
# ╠═080a4374-104e-4c30-b946-313475fb0c11
# ╠═3961c068-f268-48c5-926c-99cd5c501018
# ╟─e494556c-1106-49ce-85b4-729136b9b0b3
# ╠═efef17e1-8cd7-4d5b-a805-3d4a7345cf9d
# ╠═f5bd346f-ba38-42c5-8920-7ec127f8c547
# ╠═087cbfb4-9f42-4f9a-85cd-e92ff2004cc8
# ╠═d4cbae79-3a44-4f1f-839e-3b652bf83a42
# ╠═76af8821-a3ae-41ce-9859-363f5ef4711c
# ╠═05b5e4d4-9bea-49b5-ae51-0daa2fb8478d
# ╠═b2a050b0-2548-4a34-80ae-89f3a0bcb056
# ╠═c995f805-fc9b-47c1-bfa9-5dbcc9400806
# ╠═568bbecc-0726-43d2-ba8e-cc2c468c44b2
# ╟─976cb35a-2274-4378-94d7-6276d000c6d8
# ╠═a6796796-6f4f-470f-ad47-1b655d332905
# ╠═4f238ba9-035c-4046-ba45-604bf514be67
# ╠═b097e128-a1df-44f0-8fb7-347d9317abfc
