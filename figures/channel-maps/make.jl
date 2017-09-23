#!/usr/bin/env julia

using JLD, PyPlot, PyCall, LibHealpix

unshift!(PyVector(pyimport("sys")["path"]), "")
@pyimport my_log_scale as mls
@pyimport mpl_toolkits.axes_grid1 as tk

path = dirname(@__FILE__)

function decide_on_color_scale(img)
    pixels = vec(img)
    pixels = pixels[pixels .!= 0]
    sort!(pixels)
    N = length(pixels)
    min = pixels[round(Int, 0.00001N+1)]
    max = pixels[round(Int, 0.999N+1)]
    min, max, (max-min)/10
end

for (idx, spw) in enumerate(4:2:18)
    figure(idx, figsize=(12, 5)); clf()

    str = @sprintf("spw%02d", spw)
    img, ν, map = load(joinpath(path, "$str.jld"), "image", "frequency", "map")
    img_odd  = load(joinpath(path, "$str-odd.jld"),  "image")
    img_even = load(joinpath(path, "$str-even.jld"), "image")

    #variance = 0.5 .* ((img_odd - img).^2 .+ (img_even .- img).^2)
    #standard_deviation = sqrt.(variance)

    writehealpix(@sprintf("ovro-lwa-sky-map-%6.3fMHz.fits", ν/1e6), RingHealpixMap(map),
                 replace=true, coordsys="G")

    θ = linspace(0, 2π, 512)
    x = 2cos.(θ)
    y = sin.(θ)

    ellipse = plt[:Polygon]([x y], alpha=0)
    gca()[:add_patch](ellipse)
    min, max, base = decide_on_color_scale(img)
    imshow(img, interpolation="nearest", cmap=get_cmap("magma"),
           norm = mls.MyLogNormalize(min, max, base),
           extent=(-2, 2, -1, 1),
           clip_path=ellipse, zorder=10)
    xlim(-2, 2)
    ylim(-1, 1)
    gca()[:set_aspect]("equal")
    gca()[:get_xaxis]()[:set_visible](false)
    gca()[:get_yaxis]()[:set_visible](false)
    axis("off")

    txt = text(0.01, 0.98, @sprintf("%.3f MHz", ν/1e6),
               transform=gca()[:transAxes], fontsize=14, fontweight="bold",
               horizontalalignment="left", verticalalignment="top",
               color="black", zorder=2)

    cbar = colorbar()
    cbar[:ax][:tick_params](labelsize=12)
    cbar[:set_label]("brightness temperature (K)", fontsize=12, rotation=270)
    cbar[:ax][:get_yaxis]()[:set_label_coords](4.5, 0.5)

    #subplot(2, 1, 2)
    #ellipse = plt[:Polygon]([x y], alpha=0)
    #gca()[:add_patch](ellipse)
    #min, max, base = decide_on_color_scale(standard_deviation)
    #imshow(standard_deviation, interpolation="nearest", cmap=get_cmap("magma"),
    #       vmin=min, vmax=max,
    #       extent=(-2, 2, -1, 1),
    #       clip_path=ellipse, zorder=10)
    #xlim(-2, 2)
    #ylim(-1, 1)
    #gca()[:set_aspect]("equal")
    #gca()[:get_xaxis]()[:set_visible](false)
    #gca()[:get_yaxis]()[:set_visible](false)
    #axis("off")

    #cbar = colorbar()
    #cbar[:ax][:tick_params](labelsize=12)
    #cbar[:set_label]("brightness temperature (K)", fontsize=12, rotation=270)
    #cbar[:ax][:get_yaxis]()[:set_label_coords](4.5, 0.5)

    tight_layout()

    savefig(joinpath(path, "$str.pdf"),
            bbox_inches="tight", pad_inches=0, transparent=true)

end

