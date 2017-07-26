using JLD, PyPlot, PyCall

unshift!(PyVector(pyimport("sys")["path"]), "")
@pyimport my_log_scale as mls

path = dirname(@__FILE__)
close("all")

function plot(filename1, filename2)
    img1, ν = load(joinpath(path, filename1*".jld"), "image", "frequency")
    img2 = load(joinpath(path, filename2*".jld"), "image")
    img = img1-img2

    max = maximum(img)
    min = minimum(img)
    base = max - min
    
    figure(figsize=(12,8)); clf()
    gca()[:tick_params](axis="both", which="major", labelsize=16)
    θ = linspace(0, 2π, 512)
    x = 2cos.(θ)
    y = sin.(θ)
    ellipse = plt[:Polygon]([x y], alpha=0)
    gca()[:add_patch](ellipse)
    imshow(img, interpolation="nearest", cmap=get_cmap("magma"),
           extent=(-2, 2, -1, 1),
           clip_path=ellipse)
    gca()[:set_aspect]("equal")
    title(@sprintf("%.3f MHz", ν/1e6), fontsize=16)
    cbar = colorbar(fraction=0.02)
    cbar[:ax][:tick_params](labelsize=16)
    axis("off")
    tight_layout()

    savefig(joinpath(path, filename1*".pdf"),
            bbox_inches="tight", pad_inches=0, transparent=true)
end

plot("spw14-glamour-shot-map-rfi-restored-peeled-rainy-2048-galactic",
     "spw14-glamour-shot-map-wiener-filtered-rainy-2048-galactic")

