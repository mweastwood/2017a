#!/usr/bin/env julia

using JLD, PyPlot
using CasaCore.Measures

path = dirname(@__FILE__)
close("all")

frequencies = [3.6528e7, 4.176e7, 4.6992e7, 5.2224e7, 5.7456e7, 6.2688e7, 6.792e7, 7.3152e7]
exceptions = ("Cyg A", "Vir A", "Hya A", "Per B", "3C 353")
cutoff = frequencies .> 50e6 # Perley fluxes only valid above 50 MHz

calibrators, measured_fluxes, perley_fluxes, scaife_fluxes, baars_fluxes =
    load(joinpath(path, "source-fluxes-map-wiener-filtered.jld"),
         "calibrators", "measured_fluxes", "perley_fluxes", "scaife_fluxes", "baars_fluxes")

# manually spell this out so that we can pick the order of the plots
#names = collect(keys(calibrators))
names = ("Cyg A", "Hya A", "Lyn A", "Per B", "Vir A", "3C 48", "3C 147", "3C 286", "3C 295",
         "3C 353", "3C 380")

figure(1, figsize=(10, 10)); clf()
for (idx, name) in enumerate(names)
    direction = calibrators[name]
    lower = lowercase(replace(name, " ", ""))
    if name in exceptions
        temp = load(joinpath(path, "source-fluxes-map-$lower-peeled.jld"), "measured_fluxes")
        measured = temp[name]
    else
        measured = measured_fluxes[name]
    end

    subplot(4, 3, idx)
    gca()[:tick_params](axis="both", which="major", labelsize=14)

    max_value = maximum(measured)
    plot(frequencies/1e6, measured, "ko", zorder=3)
    if name in keys(perley_fluxes)
        model = perley_fluxes[name]
        plot(frequencies[cutoff]/1e6, model[cutoff], "k-", zorder=3)
        plot(frequencies/1e6, model, "k:", zorder=2)
        max_value = max(max_value, maximum(model))
    end
    if name in keys(scaife_fluxes)
        model = scaife_fluxes[name]
        plot(frequencies/1e6, model, "k--", zorder=3)
        max_value = max(max_value, maximum(model))
    end
    if name in keys(baars_fluxes)
        model = baars_fluxes[name]
        plot(frequencies/1e6, model, "k-.", zorder=3)
        max_value = max(max_value, maximum(model))
    end
    text(0.95, 0.95, name, transform=gca()[:transAxes], fontsize=16,
         horizontalalignment="right", verticalalignment="top",
         backgroundcolor="white", zorder=2)
    xlim(35, 75)
    ylim(0, max(100, 1.2*max_value))
    idx < 9 && plt[:setp](gca()[:get_xticklabels](), visible=false)
    idx ≥ 9 && xlabel("Frequency (MHz)", fontsize=14)
    mod(idx, 3) == 1 && ylabel("Flux (Jy)", fontsize=14)
    mod(idx, 3) == 1 && gca()[:get_yaxis]()[:set_label_coords](-0.30, 0.5)
    grid("on")
end
tight_layout()
gcf()[:subplots_adjust](hspace=0.10, wspace=0.25)
savefig(joinpath(path, "flux-scale.pdf"),
        bbox_inches="tight", pad_inches=0.1, transparent=true)

