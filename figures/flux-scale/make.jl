using JLD, PyPlot
using CasaCore.Measures

path = dirname(@__FILE__)
close("all")

frequencies = [3.6528e7,4.176e7,4.6992e7,5.2224e7,5.7456e7,6.2688e7,6.792e7,7.3152e7]
exceptions = ("Cyg A", "Vir A", "Hya A", "Per B", "3C 353")

calibrators, measured_fluxes, perley_fluxes, scaife_fluxes, baars_fluxes =
    load(joinpath(path, "source-fluxes-map-wiener-filtered.jld"),
         "calibrators", "measured_fluxes", "perley_fluxes", "scaife_fluxes", "baars_fluxes")

names = collect(keys(calibrators))

for (idx, name) in enumerate(names)
    direction = calibrators[name]
    lower = lowercase(replace(name, " ", ""))
    if name in exceptions
        temp = load(joinpath(path, "source-fluxes-map-$lower-peeled.jld"), "measured_fluxes")
        measured = temp[name]
    else
        measured = measured_fluxes[name]
    end

    figure(idx); clf()
    gca()[:tick_params](axis="both", which="major", labelsize=16)

    plot(frequencies/1e6, measured, "ko")
    if name in keys(perley_fluxes)
        model = perley_fluxes[name]
        plot(frequencies/1e6, model, "k-")
    end
    if name in keys(scaife_fluxes)
        model = scaife_fluxes[name]
        plot(frequencies/1e6, model, "k--")
    end
    if name in keys(baars_fluxes)
        model = baars_fluxes[name]
        plot(frequencies/1e6, model, "k-.")
    end
    xlim(35, 75)
    ylimits = gca()[:get_ylim]()
    ylim(0, max(100, ylimits[2]))
    title(name, fontsize=16)
    xlabel("Frequency (MHz)", fontsize=16)
    ylabel("Flux (Jy)", fontsize=16)
    grid("on")
    tight_layout()

    savefig(joinpath(path, "flux-$lower.pdf"),
            bbox_inches="tight", pad_inches=0.1, transparent=true)
end

