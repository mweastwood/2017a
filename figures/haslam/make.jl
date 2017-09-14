#!/usr/bin/env julia

using JLD, LibHealpix, PyPlot, PyCall
using Colors, PerceptualColourMaps

@pyimport mpl_toolkits.axes_grid1 as tk

path = dirname(@__FILE__)

function go()
    slope, residual = load(joinpath(path, "haslam-spectral-index.jld"), "slope", "residual")

    ν1 = 73.152
    ν2 = 408
    
    cmap_samples = cmap("D4", reverse=true)

    figure(1, figsize=(12, 5)); clf()

    θ = linspace(0, 2π, 512)
    x = 2cos.(θ)
    y = sin.(θ)
    ellipse = plt[:Polygon]([x y], alpha=0)
    gca()[:add_patch](ellipse)

    map = RingHealpixMap(solve_for_spectral_index(slope, ν1, ν2))
    img = mollweide(map, (4096, 2048))
    img[img .== 0] = NaN # this deletes contours around the edge of the map
    cs = contourf(img, -3.5:0.1:-1.5,
                  extent=(-2, 2, 1, -1), origin="lower",
                  cmap=ColorMap(cmap_samples),
                  #linewidths=1,
                  clip_path=ellipse)

    cbar = colorbar()
    #cbar[:lines][1][:set](linewidth=55)
    cbar[:ax][:tick_params](labelsize=12)
    cbar[:set_label]("local spectral index", fontsize=12, rotation=270)
    cbar[:ax][:get_yaxis]()[:set_label_coords](4.5, 0.5)

    xlim(-2, 2)
    ylim(-1, 1)
    gca()[:set_aspect]("equal")
    gca()[:get_xaxis]()[:set_visible](false)
    gca()[:get_yaxis]()[:set_visible](false)
    axis("off")

    tight_layout()

    savefig(joinpath(path, "haslam-spectral-index.pdf"),
            bbox_inches="tight", pad_inches=0, transparent=true)
end

function solve_for_spectral_index(slope, ν1, ν2)
    N = length(slope)
    index = zeros(N)
    for pixel = 1:N
        index[pixel] = _solve_for_spectral_index(slope[pixel], ν1, ν2)
    end
    index
end

function _solve_for_spectral_index(m, ν1, ν2)
    if m > 0
        return log(m)/log(ν2/ν1)
    else
        return NaN
    end
end

go()

