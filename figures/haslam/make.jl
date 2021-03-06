#!/usr/bin/env julia

using JLD, LibHealpix, PyPlot, PyCall
using Colors, PerceptualColourMaps

@pyimport mpl_toolkits.axes_grid1 as tk

path = dirname(@__FILE__)

function go()
    slope, R², mask = load(joinpath(path, "haslam-spectral-index-updated.jld"),
                           "slope", "coefficient-of-determination", "mask")

    ν1 = 36.528
    ν2 = 52.224
    ν3 = 73.152
    ν4 = 408
    brightness1 = load(joinpath(path, "spw04.jld"), "image")
    brightness2 = load(joinpath(path, "spw10.jld"), "image")
    brightness3 = load(joinpath(path, "spw18.jld"), "image")
    
    cmap_samples = cmap("D4", reverse=true)

    img = zeros(size(brightness1)..., 3)
    for y = 1:size(img, 2), x = 1:size(img, 1)
        img[x, y, 1] = brightness1[x, y] * (ν1/ν3)^2.5
        img[x, y, 2] = brightness2[x, y] * (ν2/ν3)^2.5
        img[x, y, 3] = brightness3[x, y]
    end

    figure(1, figsize=(12, 5)); clf()

    θ = linspace(0, 2π, 512)
    x = 2cos.(θ)
    y = sin.(θ)
    ellipse = plt[:Polygon]([x y], alpha=0)
    gca()[:add_patch](ellipse)

    function decide_on_color_scale(img)
        pixels = vec(img)
        pixels = pixels[pixels .!= 0]
        sort!(pixels)
        N = length(pixels)
        min = pixels[round(Int, 0.00001N+1)]
        max = pixels[round(Int, 0.999N+1)]
        min, max, (max-min)/10
    end

    img_min, img_max, img_base = decide_on_color_scale(img)
    img = clamp.(img, img_min, img_max)
    img = (log10.(img - img_min + img_base) - log10.(img_base)) ./
            (log10.(img_max - img_min + img_base) - log10.(img_base))
    imshow(img, interpolation="nearest",
           extent=(-2, 2, -1, 1),
           clip_path=ellipse)

    xlim(-2, 2)
    ylim(-1, 1)
    gca()[:set_aspect]("equal")
    gca()[:get_xaxis]()[:set_visible](false)
    gca()[:get_yaxis]()[:set_visible](false)
    axis("off")
    tight_layout()

    map = RingHealpixMap(clamp.(solve_for_spectral_index(slope, ν3, ν4), -3.5, -1.5))
    img = mollweide(map, (2048, 4096))
    mask_img = mollweide(RingHealpixMap(mask), (2048, 4096))
    R²_img = mollweide(RingHealpixMap(R²), (2048, 4096))
    img[mask_img] = NaN
    img[img .== 0] = NaN # this deletes contours around the edge of the map
    R²_img[mask_img] = NaN
    R²_img[img .== 0] = NaN # this deletes contours around the edge of the map

    cs = contour(img, -3.5:0.1:-1.5,
                 extent=(-2, 2, 1, -1), origin="lower",
                 #cmap=ColorMap(cmap_samples),
                 cmap=ColorMap("RdBu"),
                 linewidths=0.5,
                 clip_path=ellipse)

    cbar = colorbar()
    cbar[:lines][1][:set](linewidth=20)
    cbar[:ax][:tick_params](labelsize=12)
    cbar[:set_label]("local spectral index", fontsize=12, rotation=270)
    cbar[:ax][:get_yaxis]()[:set_label_coords](4.5, 0.5)

    savefig(joinpath(path, "haslam-spectral-index.pdf"),
            bbox_inches="tight", pad_inches=0, transparent=true)

    figure(2, figsize=(12, 5)); clf()
    ellipse = plt[:Polygon]([x y], alpha=0)
    gca()[:add_patch](ellipse)

    xlim(-2, 2)
    ylim(-1, 1)
    gca()[:set_aspect]("equal")
    gca()[:get_xaxis]()[:set_visible](false)
    gca()[:get_yaxis]()[:set_visible](false)
    axis("off")
    tight_layout()

    cs1 = contour(R²_img, [0.7, 0.9, 1.0],
                  extent=(-2, 2, 1, -1), origin="lower",
                  linewidths=1,
                  colors="k",
                  clip_path=ellipse)
    clabel(cs1, inline=true, fontsize=12, fontweight="bold", fmt="%.1f", rightside_up=true)
    cs2 = imshow(img, vmin=-3.5, vmax=-1.5,
                  extent=(-2, 2, 1, -1), origin="lower",
                  #cmap=ColorMap(cmap_samples),
                  cmap=get_cmap("RdBu"),
                  clip_path=ellipse)

    cbar = colorbar(cs2)
    cbar[:ax][:tick_params](labelsize=12)
    cbar[:set_label]("local spectral index", fontsize=12, rotation=270)
    cbar[:ax][:get_yaxis]()[:set_label_coords](4.5, 0.5)

    savefig(joinpath(path, "better-haslam-spectral-index.pdf"),
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
        index = log(m)/log(ν2/ν1)
    else
        return -10
    end
end

go()

