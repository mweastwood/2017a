#!/usr/bin/env julia

using JLD, PyPlot, LibHealpix

path = dirname(@__FILE__)

δ = load(joinpath(path, "comparison-with-guzman.jld"), "difference")
img = mollweide(RingHealpixMap(δ))

figure(1, figsize=(12, 5)); clf()

θ = linspace(0, 2π, 512)
x = 2cos.(θ)
y = sin.(θ)

ellipse = plt[:Polygon]([x y], alpha=0)
gca()[:add_patch](ellipse)
imshow(img, interpolation="nearest", cmap=get_cmap("RdBu_r"),
       vmin=-0.5, vmax=+0.5,
       extent=(-2, 2, -1, 1),
       clip_path=ellipse, zorder=10)
xlim(-2, 2)
ylim(-1, 1)
gca()[:set_aspect]("equal")
gca()[:get_xaxis]()[:set_visible](false)
gca()[:get_yaxis]()[:set_visible](false)
axis("off")

cbar = colorbar()
cbar[:ax][:tick_params](labelsize=12)
cbar[:set_label]("fractional difference", fontsize=12, rotation=270)
cbar[:ax][:get_yaxis]()[:set_label_coords](4.0, 0.5)

tight_layout()

savefig(joinpath(path, "guzman.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

