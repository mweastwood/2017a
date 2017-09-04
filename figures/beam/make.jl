#!/usr/bin/env julia

using JLD, PyPlot, PyCall, CasaCore.Measures

@pyimport mpl_toolkits.axes_grid1 as tk
@pyimport matplotlib.patheffects as pe

path = dirname(@__FILE__)
figure(1, figsize=(12, 4)); clf()

sources = Dict("Cyg A" => Direction(dir"J2000", "19h59m28.35663s", "+40d44m02.0970s"),
               "Cas A" => Direction(dir"J2000", "23h23m24.000s", "+58d48m54.00s"),
               "Tau A" => Direction(dir"J2000", "05h34m31.94s", "+22d00m52.2s"),
               "Vir A" => Direction(dir"J2000", "12h30m49.42338s", "+12d23m28.0439s"),
               "Her A" => Direction(dir"J2000", "16h51m11.4s", "+04d59m20s"),
               "Hya A" => Direction(dir"J2000", "09h18m05.651s", "-12d05m43.99s"),
               "Per B" => Direction(dir"J2000", "04h37m04.3753s", "+29d40m13.819s"),
               "3C 353" => Direction(dir"J2000", "17h20m28.147s", "-00d58m47.12s"))

ovro_lwa = Position(pos"ITRF", -2.40927462614919e6, -4.477838733582964e6, 3.839370728766106e6)
times = linspace(4.994049600941745e9, 4.994150416022397e9, 7756)

tracks = Dict{String, Tuple{Vector{Float64}, Vector{Float64}}}()
frame = ReferenceFrame()
Measures.set!(frame, ovro_lwa)
for name in keys(sources)
    direction = sources[name]
    l = Float64[]
    m = Float64[]
    for t in times
        Measures.set!(frame, Epoch(epoch"UTC", t*seconds))
        azel = measure(frame, direction, dir"AZEL")
        az = longitude(azel)
        el =  latitude(azel)
        if el > 0
            push!(l, sin(az)*cos(el))
            push!(m, cos(az)*cos(el))
        else
            push!(l, NaN)
            push!(m, NaN)
        end
    end
    tracks[name] = (l, m)
end

frequencies = [3.6528e7, 5.2224e7, 7.3152e7]
filenames = ["spw04-beam", "spw10-beam", "spw18-beam"]

function plot_image(filename)
    img = load(joinpath(path, filename*".jld"), "I-image")
    gca()[:tick_params](axis="both", which="major", labelsize=12)
    gca()[:set_aspect]("equal")
    circle = plt[:Circle]((0, 0), 1, alpha=0)
    gca()[:add_patch](circle)
    out = imshow(img, extent=(-1, 1, -1, 1), interpolation="nearest", vmin=0, vmax=1,
                 cmap=get_cmap("magma"), clip_path=circle)
    xlim(1, -1)
    ylim(-1, 1)
    out
end

function plot_tracks()
    for (l, m) in values(tracks)
        plot(l, m, "w-", alpha=0.5)
    end
end

function label(idx)
    txt = text(0.95, 0.95, @sprintf("%.3f MHz", frequencies[idx]/1e6),
               transform=gca()[:transAxes], fontsize=16, fontweight="bold",
               horizontalalignment="right", verticalalignment="top",
               color="white", zorder=2)
    #txt[:set_bbox](Dict(:facecolor=>"white", :alpha=>0.75, :edgecolor=>"none"))
    txt[:set_path_effects]([pe.Stroke(linewidth=2, foreground="black"),
                            pe.Normal()])
end

ax = gca()
divider = tk.make_axes_locatable(ax)

_im = plot_image(filenames[1])
plot_tracks()
label(1)
xlabel("l (direction cosine)", fontsize=12)
ylabel("m (direction cosine)", fontsize=12)
xticks([1.0, 0.5, 0.0, -0.5])
yticks([1.0, 0.5, 0.0, -0.5, -1.0])

_ax = divider[:append_axes]("right", size="100%", pad=0.10)
plot_image(filenames[2])
plot_tracks()
label(2)
xlabel("l (direction cosine)", fontsize=12)
plt[:setp](gca()[:get_yticklabels](), visible=false)
xticks([1.0, 0.5, 0.0, -0.5])
yticks([1.0, 0.5, 0.0, -0.5, -1.0])

_ax = divider[:append_axes]("right", size="100%", pad=0.10)
plot_image(filenames[3])
plot_tracks()
label(3)
xlabel("l (direction cosine)", fontsize=12)
plt[:setp](gca()[:get_yticklabels](), visible=false)
xticks([1.0, 0.5, 0.0, -0.5, -1.0])
yticks([1.0, 0.5, 0.0, -0.5, -1.0])

cax = divider[:append_axes]("right", size="5%", pad=0.10)
cbar = colorbar(_im, cax=cax)
cbar[:ax][:tick_params](labelsize=12)
cbar[:set_label]("normalized amplitude", fontsize=12, rotation=270)
cbar[:ax][:get_yaxis]()[:set_label_coords](4.5, 0.5)

tight_layout()

savefig(joinpath(path, "beam.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

