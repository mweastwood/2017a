#!/usr/bin/env julia

using JLD, PyPlot, CasaCore.Measures

path = dirname(@__FILE__)
figure(1, figsize=(12, 8)); clf()

names, t, I, flags = load(joinpath(path, "light-curves-rainy.jld"),
                          "names", "t", "I", "flags")

names′, t′, I′, flags′ = load(joinpath(path, "expected-light-curves-rainy.jld"),
                              "names", "t", "I", "flags")

names, _, δra, δdec, flags_offset = load(joinpath(path, "refraction-curves-rainy.jld"),
                                         "names", "t", "dra", "ddec", "flags")


function plot_light_curve(spw, src, marker, color, label)
    f = flags[spw][src, :]
    x = copy(t[spw])
    y = I[spw][src, :]
    x -= x[1]
    x /= 3600
    x = x[.!f]
    y = y[.!f]
    scatter(x, y, marker=marker, color=color, s=10, edgecolors="w", lw=0, label=label)

    f = flags′[spw][src, :]
    x = copy(t′[spw])
    y = I′[spw][src, :]
    x -= x[1]
    x /= 3600
    x[f] = NaN
    y[f] = NaN
    plot(x, y, "k-", lw=1, label="_nolegend_")
end

function plot_offset(spw, src, color)
    f = flags_offset[spw][src, :]
    x = copy(t[spw])
    y1 = δra[spw][src, :]
    y2 = δdec[spw][src, :]
    y = hypot.(y1, y2)
    x -= x[1]
    x /= 3600
    y = 60rad2deg.(y)
    x[f] = NaN
    y[f] = NaN
    plot(x, y, "-", color=color, lw=1)
end

subplot(4, 1, 1)
gca()[:tick_params](axis="both", which="major", labelsize=12)
plot_light_curve( 4, 1, ".", "#d62728", "36.528 MHz")
plot_light_curve(18, 1, ".", "#1f77b4", "73.152 MHz")
text(0.01, 0.95, "(a) Cyg A",
     transform=gca()[:transAxes], fontsize=14, fontweight="bold",
     horizontalalignment="left", verticalalignment="top",
     color="black", zorder=2)
xlim(0, 28)
ylim(0, 35000)
ylabel("apparent flux (Jy)", fontsize=12)
plt[:setp](gca()[:get_xticklabels](), visible=false)

annotate("occulted by\nmountains", xy=(22, 1000), xytext=(21, 3000),
         arrowprops=Dict(:width=>1, :headwidth=>5, :headlength=>5,
                         :shrink=>0.05, :facecolor=>"black"),
         horizontalalignment="right",
         fontsize=12)

subplot(4, 1, 2)
gca()[:tick_params](axis="both", which="major", labelsize=12)
plot_light_curve( 4, 2, ".", "#d62728", "36.528 MHz")
plot_light_curve(18, 2, ".", "#1f77b4", "73.152 MHz")
text(0.01, 0.95, "(b) Cas A",
     transform=gca()[:transAxes], fontsize=14, fontweight="bold",
     horizontalalignment="left", verticalalignment="top",
     color="black", zorder=2)
xlim(0, 28)
ylim(0, 35000)
ylabel("apparent flux (Jy)", fontsize=12)
plt[:setp](gca()[:get_xticklabels](), visible=false)

subplot(4, 1, 3)
gca()[:tick_params](axis="both", which="major", labelsize=12)
plot_offset( 4, 1, "#d62728")
plot_offset(18, 1, "#1f77b4")
text(0.01, 0.95, "(c) Cyg A",
     transform=gca()[:transAxes], fontsize=14, fontweight="bold",
     horizontalalignment="left", verticalalignment="top",
     color="black", zorder=2)
xlim(0, 28)
ylim(0, 24)
ylabel("offset (arcmin)", fontsize=12)
plt[:setp](gca()[:get_xticklabels](), visible=false)

subplot(4, 1, 4)
gca()[:tick_params](axis="both", which="major", labelsize=12)
plot_offset( 4, 2, "#d62728")
plot_offset(18, 2, "#1f77b4")
text(0.01, 0.95, "(d) Cas A",
     transform=gca()[:transAxes], fontsize=14, fontweight="bold",
     horizontalalignment="left", verticalalignment="top",
     color="black", zorder=2)
xlim(0, 28)
ylim(0, 24)
xlabel("time from start of observation (hours)", fontsize=12)
ylabel("offset (arcmin)", fontsize=12)

tight_layout()
gcf()[:subplots_adjust](hspace=0)

savefig(joinpath(path, "scintillation-refraction.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

