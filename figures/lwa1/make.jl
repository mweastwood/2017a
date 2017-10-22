#!/usr/bin/env julia

using JLD, PyPlot, LibHealpix
using CasaCore.Measures

path = dirname(@__FILE__)

originals, lwa1, ovro, masks = load(joinpath(path, "lwa1-comparison.jld"),
                                    "lwa1-original", "lwa1", "ovro", "masks")
ν = ["38 MHz", "40 MHz", "45 MHz", "50 MHz", "60 MHz", "70 MHz"]

function rotate_to_galactic(map)
    frame = ReferenceFrame()
    z = Direction(dir"J2000", 0, 0, 1)
    z_ = measure(frame, z, dir"GALACTIC")
    x = Direction(dir"J2000", 1, 0, 0)
    x_ = measure(frame, x, dir"GALACTIC")
    zvec = [z_.x, z_.y, z_.z]
    xvec = [x_.x, x_.y, x_.z]
    yvec = cross(zvec, xvec)
    pixels = zeros(length(map))
    for idx = 1:length(map)
        vec = pix2vec(map, idx)
        θ = acos(dot(vec, zvec))
        ϕ = atan2(dot(vec, yvec), dot(vec, xvec))
        pixels[idx] = LibHealpix.interpolate(map, θ, ϕ)
    end
    RingHealpixMap(pixels)
end

figure(1, figsize=(12, 8)); clf()
axes = []
for idx = 1:6
    global _im
    subplot2grid((3, 2), (div(idx-1, 2), mod(idx-1, 2)))
    push!(axes, gca())

    θ = linspace(0, 2π, 512)
    x = 2cos.(θ)
    y = sin.(θ)
    ellipse = plt[:Polygon]([x y], alpha=0)
    gca()[:add_patch](ellipse)

    δ = (ovro[idx]-lwa1[idx])./originals[idx]
    δ[.!masks[idx]] = NaN
    δmap = rotate_to_galactic(RingHealpixMap(δ))

    _im = imshow(mollweide(δmap), interpolation="nearest",
                 vmin=-0.5, vmax=+0.5,
                 cmap=get_cmap("RdBu_r"),
                 extent=(-2, 2, -1, 1),
                 clip_path=ellipse, zorder=1)
    xlim(-2, 2)
    ylim(-1, 1)
    gca()[:set_aspect]("equal")
    gca()[:get_xaxis]()[:set_visible](false)
    gca()[:get_yaxis]()[:set_visible](false)
    axis("off")

    text(0.01, 0.99, ν[idx],
         transform=gca()[:transAxes], fontsize=16, fontweight="bold",
         horizontalalignment="left", verticalalignment="top",
         color="black", zorder=2)
end

tight_layout()
cbar = colorbar(_im, ax=axes)

gcf()[:subplots_adjust](hspace=0.05, wspace=0.05, right=0.8)
cbar[:ax][:tick_params](labelsize=12)
cbar[:set_label]("fractional difference", fontsize=12, rotation=270)
cbar[:ax][:get_yaxis]()[:set_label_coords](3.0, 0.5)

savefig(joinpath(path, "lwa1.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

