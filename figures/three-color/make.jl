#!/usr/bin/env julia

using JLD, LibHealpix, PyPlot, PyCall

@pyimport mpl_toolkits.axes_grid1 as tk

path = dirname(@__FILE__)

function allsky()
    ν1 = 36.528
    ν2 = 52.224
    ν3 = 73.152
    brightness1 = load(joinpath(path, "spw04.jld"), "image")
    brightness2 = load(joinpath(path, "spw10.jld"), "image")
    brightness3 = load(joinpath(path, "spw18.jld"), "image")
    
    img = zeros(size(brightness1)..., 3)
    for y = 1:size(img, 2), x = 1:size(img, 1)
        img[x, y, 1] = brightness1[x, y] * (ν1/ν3)^2.5
        img[x, y, 2] = brightness2[x, y] * (ν2/ν3)^2.5
        img[x, y, 3] = brightness3[x, y]
    end

    dpi = 256
    figure(1, figsize=(size(img, 2)÷dpi, size(img, 1)÷dpi), dpi=dpi); clf()
    gcf()[:subplots_adjust](left=0, right=1, bottom=0, top=1)

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

    savefig(joinpath(path, "ovro-lwa-sky-map.pdf"),
            bbox_inches="tight", pad_inches=0, transparent=true)
    savefig(joinpath(path, "ovro-lwa-sky-map.png"),
            bbox_inches="tight", pad_inches=0, transparent=true)
end

function cutout(map)
    lrange = linspace(0, 220, 2048)
    brange = linspace( -30,  30, 1024)
    img = zeros(length(brange), length(lrange))
    for (jdx, l) in enumerate(lrange), (idx, b) in enumerate(brange)
        img[idx, jdx] = LibHealpix.interpolate(map, deg2rad(90-b), deg2rad(l))
    end
    img, lrange, brange
end

function galaxy()
    ν1 = 36.528
    ν2 = 52.224
    ν3 = 73.152
    map1 = RingHealpixMap(load(joinpath(path, "spw04.jld"), "map"))
    map2 = RingHealpixMap(load(joinpath(path, "spw10.jld"), "map"))
    map3 = RingHealpixMap(load(joinpath(path, "spw18.jld"), "map"))
    img1, lrange, brange = cutout(map1)
    img2, lrange, brange = cutout(map2)
    img3, lrange, brange = cutout(map3)

    img = zeros(size(img1)..., 3)
    for y = 1:size(img, 2), x = 1:size(img, 1)
        img[x, y, 1] = img1[x, y] * (ν1/ν3)^2.5
        img[x, y, 2] = img2[x, y] * (ν2/ν3)^2.5
        img[x, y, 3] = img3[x, y]
    end

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

    figure(2, figsize=(12, 5)); clf()
    imshow(img, interpolation="nearest",
           origin="lower",
           extent=(minimum(lrange), maximum(lrange), minimum(brange), maximum(brange)))
    xlabel("l (degrees)", fontsize=12)
    ylabel("b (degrees)", fontsize=12)
    
    xlim(minimum(lrange), maximum(lrange))
    ylim(minimum(brange), maximum(brange))
    gca()[:set_aspect]("equal")
    gca()[:invert_xaxis]()
    tight_layout()

    savefig(joinpath(path, "ovro-lwa-galactic-plane.pdf"),
            bbox_inches="tight", pad_inches=0, transparent=true)
end

allsky()
galaxy()

