#!/usr/bin/env julia

using JLD, PyPlot, PyCall

@pyimport mpl_toolkits.axes_grid1 as tk

path = dirname(@__FILE__)
figure(1, figsize=(12, 4)); clf()

frequencies = [3.6528e7, 5.2224e7, 7.3152e7]
filenames = ["spw04-psf-+45-degrees", "spw10-psf-+45-degrees", "spw18-psf-+45-degrees"]

function plot_image(filename)
    img = load(joinpath(path, filename*".jld"), "img")
    img = img[51:151, 51:151]
    gca()[:tick_params](axis="both", which="major", labelsize=12)
    gca()[:set_aspect]("equal")
    out = imshow(img.', interpolation="nearest", cmap=get_cmap("magma"),
                 vmin=-0.2, vmax=1.0,
                 extent=(150, -150, -150, 150))
    xlim(140, -140)
    ylim(-140, 140)
    out
end

function label(idx)
    text(0.95, 0.95, @sprintf("%.3f MHz", frequencies[idx]/1e6),
         transform=gca()[:transAxes], fontsize=16, fontweight="bold",
         horizontalalignment="right", verticalalignment="top",
         color="white", zorder=2)
end

g = gs.GridSpec(1, 3, height_ratios=[1])

ax = gca()
divider = tk.make_axes_locatable(ax)

_im = plot_image(filenames[1])
label(1)
xlabel("ΔRA (arcmin)", fontsize=12)
ylabel("Δdec (arcmin)", fontsize=12)

_ax = divider[:append_axes]("right", size="100%", pad=0.10)
plot_image(filenames[2])
label(2)
xlabel("ΔRA (arcmin)", fontsize=12)
plt[:setp](gca()[:get_yticklabels](), visible=false)

_ax = divider[:append_axes]("right", size="100%", pad=0.10)
plot_image(filenames[3])
label(3)
xlabel("ΔRA (arcmin)", fontsize=12)
plt[:setp](gca()[:get_yticklabels](), visible=false)

cax = divider[:append_axes]("right", size="5%", pad=0.10)
cbar = colorbar(_im, cax=cax)
cbar[:ax][:tick_params](labelsize=12)
cbar[:set_label]("normalized amplitude", fontsize=12, rotation=270)
cbar[:ax][:get_yaxis]()[:set_label_coords](4.5, 0.5)

tight_layout()

savefig(joinpath(path, "psf.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

