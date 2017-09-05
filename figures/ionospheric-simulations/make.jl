#!/usr/bin/env julia

using JLD, PyPlot, PyCall

@pyimport mpl_toolkits.axes_grid1 as tk

path = dirname(@__FILE__)
figure(1, figsize=(12, 4)); clf()

max = 1.0
min = 0.0

function plot_image(filename)
    global max, min
    img = load(joinpath(path, filename*".jld"), "img")
    if filename == "base-image"
        max = maximum(img)
        img ./= max
        min = minimum(img)
    else
        img ./= max
    end
    img = img[51:151, 51:151]
    gca()[:tick_params](axis="both", which="major", labelsize=12)
    gca()[:set_aspect]("equal")
    out = imshow(img.', interpolation="nearest", cmap=get_cmap("magma"),
                 vmin=-0.1, vmax=0.3,
                 extent=(150, -150, -150, 150))
    xlim(140, -140)
    ylim(-140, 140)
    out
end

function label(string)
    text(0.95, 0.95, string,
         transform=gca()[:transAxes], fontsize=16, fontweight="bold",
         horizontalalignment="right", verticalalignment="top",
         color="white", zorder=2)
end

ax = gca()
divider = tk.make_axes_locatable(ax)

_im = plot_image("base-image")
label("no ionosphere")
xlabel("ΔRA (arcmin)", fontsize=12)
ylabel("Δdec (arcmin)", fontsize=12)

_ax = divider[:append_axes]("right", size="100%", pad=0.10)
plot_image("scintillation-flux")
label("scintillation only")
xlabel("ΔRA (arcmin)", fontsize=12)
plt[:setp](gca()[:get_yticklabels](), visible=false)

_ax = divider[:append_axes]("right", size="100%", pad=0.10)
plot_image("refraction-position")
label("refraction only")
xlabel("ΔRA (arcmin)", fontsize=12)
plt[:setp](gca()[:get_yticklabels](), visible=false)

cax = divider[:append_axes]("right", size="5%", pad=0.10)
cbar = colorbar(_im, cax=cax)
cbar[:ax][:tick_params](labelsize=12)
cbar[:set_label]("normalized amplitude", fontsize=12, rotation=270)
cbar[:ax][:get_yaxis]()[:set_label_coords](5.5, 0.5)

tight_layout()

savefig(joinpath(path, "ionospheric-simulations.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

