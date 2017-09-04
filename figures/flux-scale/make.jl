#!/usr/bin/env julia

using JLD, PyPlot
using CasaCore.Measures

path = dirname(@__FILE__)

frequencies = [3.6528e7, 4.176e7, 4.6992e7, 5.2224e7, 5.7456e7, 6.2688e7, 6.792e7, 7.3152e7]
model_frequencies = linspace(10e6, 100e6, 201)

everything, odd, even, baars, perley, scaife =
    load(joinpath(path, "spectra.jld"),
         "everything", "odd", "even", "baars", "perley", "scaife")


# manually spell this out so that we can pick the order of the plots
names = ("Cyg A", "Hya A", "Lyn A", "Per B", "Vir A", "3C 48", "3C 147", "3C 286", "3C 295",
         "3C 353", "3C 380")

figure(1, figsize=(12, 10)); clf()
for (idx, name) in enumerate(names)
    μ = everything[name]
    σ = sqrt.(0.5*(abs2.(odd[name]-μ) + abs2.(even[name]-μ)))
    max_value = maximum(μ)

    subplot(4, 3, idx)
    gca()[:tick_params](axis="both", which="major", labelsize=12)
    errorbar(frequencies/1e6, μ, yerr=σ, fmt="k.", zorder=3)

    if name in keys(perley)
        model = perley[name]
        cutoff = 50e6 .< model_frequencies .< 75e6
        plot(model_frequencies[cutoff]/1e6, model[cutoff], "k-", zorder=3)
        cutoff = 35e6 .< model_frequencies .< 75e6
        plot(model_frequencies[cutoff]/1e6, model[cutoff], "k:", zorder=2)
        #max_value = max(max_value, maximum(model))
    end
    if name in keys(scaife)
        model = scaife[name]
        cutoff = 35e6 .< model_frequencies .< 75e6
        plot(model_frequencies[cutoff]/1e6, model[cutoff], "k--", zorder=3)
        #max_value = max(max_value, maximum(model))
    end
    if name in keys(baars)
        model = baars[name]
        cutoff = 35e6 .< model_frequencies .< 75e6
        plot(model_frequencies[cutoff]/1e6, model[cutoff], "k-.", zorder=3)
        #max_value = max(max_value, maximum(model))
    end

    text(0.95, 0.95, name, transform=gca()[:transAxes], fontsize=14,
         horizontalalignment="right", verticalalignment="top",
         backgroundcolor="white", zorder=2)
    xlim(35, 75)
    ylim(0, max(100.0, gca()[:get_ylim]()[2]))
    idx < 9 && plt[:setp](gca()[:get_xticklabels](), visible=false)
    idx ≥ 9 && xlabel("Frequency (MHz)", fontsize=12)
    mod(idx, 3) == 1 && ylabel("Flux (Jy)", fontsize=12)
    mod(idx, 3) == 1 && gca()[:get_yaxis]()[:set_label_coords](-0.20, 0.5)
    grid("on")
end
tight_layout()
gcf()[:subplots_adjust](hspace=0.10, wspace=0.20)

savefig(joinpath(path, "flux-scale.pdf"),
        bbox_inches="tight", pad_inches=0.1, transparent=true)

