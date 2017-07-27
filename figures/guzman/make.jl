using JLD, PyPlot

path = dirname(@__FILE__)
#close("all")

guzman, lwa = load(joinpath(path, "comparison-with-guzman.jld"), "guzman", "lwa")

figure(1); clf()
θ = linspace(0, 2π, 512)
x = 2cos.(θ)
y = sin.(θ)
ellipse = plt[:Polygon]([x y], alpha=0)
gca()[:add_patch](ellipse)
imshow((lwa-guzman)./guzman, interpolation="nearest", cmap=get_cmap("RdBu_r"),
       vmin=-0.5, vmax=+0.5,
       extent=(-2, 2, -1, 1), clip_path=ellipse)
gca()[:set_aspect]("equal")
axis("off")
cbar = colorbar(fraction=0.02)
cbar[:ax][:tick_params](labelsize=16)
tight_layout()

savefig(joinpath(path, "guzman-comparison.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

