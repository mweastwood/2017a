#!/usr/bin/env julia

using JLD, PyPlot

path = dirname(@__FILE__)
figure(1, figsize=(6, 6)); clf()

# Create the antenna layout panel

matrix = readdlm(joinpath(path, "antenna-layout.txt"))
east  = matrix[:, 1]
north = matrix[:, 2]
up    = matrix[:, 3]
east -= 2

core = 1:251
leda = 252:256
expansion = 257:288

gca()[:tick_params](axis="both", which="major", labelsize=12)

scatter(east[core], north[core], marker=".", c="k", s=20, lw=0)
scatter(east[leda], north[leda], marker="+", c="k", s=50)
scatter(east[expansion], north[expansion], marker="^", c="k", s=20)
gca()[:set_aspect]("equal")
xlabel("distance east (m)", fontsize=12)
ylabel("distance north (m)", fontsize=12)

tight_layout()

savefig(joinpath(path, "antenna-layout.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

