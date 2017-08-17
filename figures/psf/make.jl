#!/usr/bin/env julia

using JLD, PyPlot

path = dirname(@__FILE__)
figure(1, figsize=(15, 5)); clf()

# Create the antenna layout panel

matrix = readdlm(joinpath(path, "antenna-layout.txt"))
east  = matrix[:, 1]
north = matrix[:, 2]
up    = matrix[:, 3]
east -= 2

core = 1:251
leda = 252:256
expansion = 257:288

subplot(1, 3, 1)
gca()[:tick_params](axis="both", which="major", labelsize=14)

scatter(east[core], north[core], marker="o", c="k", s=6, lw=0)
scatter(east[leda], north[leda], marker="+", c="k", s=50)
scatter(east[expansion], north[expansion], marker="^", c="k", s=20)
gca()[:set_aspect]("equal")
xlabel("distance east (m)", fontsize=14)
ylabel("distance north (m)", fontsize=14)

# Create the psf panels

frequencies = [3.6528e7, 7.3152e7]
filenames = ["spw04-psf-+45-degrees", "spw18-psf-+45-degrees"]

global _im
for idx = 1:length(filenames)
    subplot(1, 3, idx+1)
    filename = filenames[idx]

    img = load(joinpath(path, filename*".jld"), "img")
    img = img[51:151, 51:151]
    
    gca()[:tick_params](axis="both", which="major", labelsize=14)
    
    _im = imshow(img.', interpolation="nearest", cmap=get_cmap("magma"),
                 vmin=-0.2, vmax=1.0,
                 extent=(150, -150, -150, 150))
    gca()[:set_aspect]("equal")
    idx == 2 && plt[:setp](gca()[:get_yticklabels](), visible=false)
    xlabel("ΔRA" * " (arcmin)", fontsize=14)
    idx == 1 && ylabel("Δdec" * " (arcmin)", fontsize=14)
    text(0.95, 0.95, @sprintf("%.3f MHz", frequencies[idx]/1e6),
         transform=gca()[:transAxes], fontsize=16, fontweight="bold",
         horizontalalignment="right", verticalalignment="top",
         color="white", zorder=2)
end

gcf()[:subplots_adjust](wspace=0.30)
bbox=gca()[:get_position]()
gca()[:set_position]([bbox[:x0] - 0.05, bbox[:y0], bbox[:x1]-bbox[:x0], bbox[:y1]-bbox[:y0]])

cax = gcf()[:add_axes]([0.86, 0.17, 0.02, 0.65])
cbar = colorbar(_im, cax=cax)
cbar[:ax][:tick_params](labelsize=14)
cbar[:set_label]("normalized amplitude", fontsize=14, rotation=270)
cbar[:ax][:get_yaxis]()[:set_label_coords](3.5, 0.5)

savefig(joinpath(path, "psf.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

