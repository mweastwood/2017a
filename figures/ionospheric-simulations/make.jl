#!/usr/bin/env julia

using JLD, PyPlot, PyCall

@pyimport mpl_toolkits.axes_grid1 as tk

path = dirname(@__FILE__)

function plot_image(spw, filename)
    img = load(joinpath(path, filename*".jld"), "img")
    img′ = load(joinpath(path, "base-image-$spw.jld"), "img")
    img .-= img′
    img ./= maximum(img′)
    img .*= 100

    max = maximum(abs.(img))
    min = -max


    img = img[51:151, 51:151]
    gca()[:tick_params](axis="both", which="major", labelsize=12)
    gca()[:set_aspect]("equal")
    out = imshow(img.', interpolation="nearest", cmap=get_cmap("magma"),
                 vmin=min, vmax=max,
                 extent=(150, -150, -150, 150))
    xlim(140, -140)
    ylim(-140, 140)
    out
end

function label(spw, string)
    ν = spw == 4 ? "36.528 MHz" : "73.152 MHz"
    text(0.05, 0.95, string,
         transform=gca()[:transAxes], fontsize=14, fontweight="bold",
         horizontalalignment="left", verticalalignment="top",
         color="white", zorder=2)
    text(0.95, 0.95, ν,
         transform=gca()[:transAxes], fontsize=14, fontweight="bold",
         horizontalalignment="right", verticalalignment="top",
         color="white", zorder=2)
end

for (idx, stuff) in enumerate(((4, "scintillation-flux"), (4, "refraction-position"),
                               (18, "scintillation-flux"), (18, "refraction-position")))
    spw, filename = stuff
    figure(idx, figsize=(6, 4)); clf()
    ax = gca()
    divider = tk.make_axes_locatable(ax)
    
    _im = plot_image(spw, "$filename-$spw")
    xlabel("ΔRA (arcmin)", fontsize=12)
    ylabel("Δdec (arcmin)", fontsize=12)

    if contains(filename, "scintillation")
        label(spw, "scintillation")
    else
        label(spw, "refractive offsets")
    end
    
    cax = divider[:append_axes]("right", size="5%", pad=0.10)
    cbar = colorbar(_im, cax=cax)
    cbar[:ax][:tick_params](labelsize=14)
    cbar[:set_label]("percent difference", fontsize=10, rotation=270)
    cbar[:ax][:get_yaxis]()[:set_label_coords](5.5, 0.5)
    
    tight_layout()
    
    name = contains(filename, "scintillation") ? "scintillation" : "refraction"
    savefig(joinpath(path, "$name-$spw.pdf"),
            bbox_inches="tight", pad_inches=0, transparent=true)
end

