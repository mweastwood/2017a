#!/usr/bin/env julia

using JLD, PyPlot, PyCall

unshift!(PyVector(pyimport("sys")["path"]), "")
@pyimport my_log_scale as mls
close("all")

path = dirname(@__FILE__)

figure(1, figsize=(10, 8)); clf()
for (idx, spw) in enumerate(4:2:18)
    str = @sprintf("spw%02d", spw)
    filename = "$str-glamour-shot-map-wiener-filtered-rainy-2048-galactic"
    img, ν = load(joinpath(path, filename*".jld"), "image", "frequency")

    max = maximum(img)/5
    min = minimum(img)
    base = max - min
    
    subplot(4, 2, idx)
    θ = linspace(0, 2π, 512)
    x = 2cos.(θ)
    y = sin.(θ)
    ellipse = plt[:Polygon]([x y], alpha=0)
    gca()[:add_patch](ellipse)
    imshow(img, interpolation="nearest", cmap=get_cmap("magma"),
           norm = mls.MyLogNormalize(min, max, base),
           extent=(-2, 2, -1, 1),
           clip_path=ellipse, zorder=10)
    xlim(-2, 2)
    ylim(-1, 1)
    gca()[:set_aspect]("equal")
    gca()[:get_xaxis]()[:set_visible](false)
    gca()[:get_yaxis]()[:set_visible](false)
    title(@sprintf("%.3f MHz", ν/1e6), fontsize=10)
    axis("off")
    cbar = colorbar(fraction=0.07, orientation="vertical")
    cbar[:ax][:tick_params](labelsize=12)
    cbar[:set_label]("Temperature (K)", fontsize=10, rotation=270)
    cbar[:ax][:get_yaxis]()[:set_label_coords](12.0, 0.5)

end
tight_layout()
gcf()[:subplots_adjust](hspace=0.25, wspace=-0.05)

savefig(joinpath(path, "channel-maps.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)
savefig(joinpath(path, "channel-maps.png"),
        bbox_inches="tight", pad_inches=0, transparent=true)

