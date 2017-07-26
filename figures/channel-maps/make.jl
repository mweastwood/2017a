using JLD, PyPlot, PyCall

unshift!(PyVector(pyimport("sys")["path"]), "")
@pyimport my_log_scale as mls

path = dirname(@__FILE__)
close("all")

function plot(filename)
    img, ν = load(joinpath(path, filename*".jld"), "image", "frequency")

    max = maximum(img)/5
    min = minimum(img)
    base = max - min
    
    figure(); clf()
    gca()[:tick_params](axis="both", which="major", labelsize=16)
    θ = linspace(0, 2π, 512)
    x = 2cos.(θ)
    y = sin.(θ)
    ellipse = plt[:Polygon]([x y], alpha=0)
    gca()[:add_patch](ellipse)
    imshow(img, interpolation="nearest", cmap=get_cmap("magma"),
           norm = mls.MyLogNormalize(min, max, base),
           extent=(-2, 2, -1, 1),
           clip_path=ellipse)
    gca()[:set_aspect]("equal")
    title(@sprintf("%.3f MHz", ν/1e6), fontsize=16)
    axis("off")
    cbar = colorbar(fraction=0.02)
    cbar[:ax][:tick_params](labelsize=16)
    tight_layout()

    savefig(joinpath(path, filename*".pdf"),
            bbox_inches="tight", pad_inches=0, transparent=true)
end

plot("spw04-glamour-shot-map-wiener-filtered-rainy-2048-galactic")
plot("spw06-glamour-shot-map-wiener-filtered-rainy-2048-galactic")
plot("spw08-glamour-shot-map-wiener-filtered-rainy-2048-galactic")
plot("spw10-glamour-shot-map-wiener-filtered-rainy-2048-galactic")
plot("spw12-glamour-shot-map-wiener-filtered-rainy-2048-galactic")
plot("spw14-glamour-shot-map-wiener-filtered-rainy-2048-galactic")
plot("spw16-glamour-shot-map-wiener-filtered-rainy-2048-galactic")
plot("spw18-glamour-shot-map-wiener-filtered-rainy-2048-galactic")

