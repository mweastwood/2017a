#!/usr/bin/env julia

using JLD, PyPlot, CasaCore.Measures

path = dirname(@__FILE__)
figure(1, figsize=(12, 4)); clf()

names, t, I, flags = load(joinpath(path, "light-curves-rainy.jld"),
                          "names", "t", "I", "flags")

names′, t′, I′, flags′ = load(joinpath(path, "expected-light-curves-rainy.jld"),
                              "names", "t", "I", "flags")

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

subplot(1, 2, 1)
gca()[:tick_params](axis="both", which="major", labelsize=12)
plot_light_curve( 4, 1, ".", "#d62728", "36.528 MHz")
plot_light_curve(18, 1, ".", "#1f77b4", "73.152 MHz")
text(0.95, 0.95, names[4][1],
     transform=gca()[:transAxes], fontsize=14, fontweight="bold",
     horizontalalignment="right", verticalalignment="top",
     color="black", zorder=2)
#legend("upper right")
text(0.95, 0.86, "36.528 MHz",
     transform=gca()[:transAxes], fontsize=12, fontweight="bold",
     horizontalalignment="right", verticalalignment="top",
     color="#d62728", zorder=2)
text(0.95, 0.77, "73.152 MHz",
     transform=gca()[:transAxes], fontsize=12, fontweight="bold",
     horizontalalignment="right", verticalalignment="top",
     color="#1f77b4", zorder=2)
xlim(0, 28)
ylim(0, 35000)
xlabel("time from start of observation (hours)", fontsize=12)
ylabel("apparent flux including antenna gain (Jy)", fontsize=12)

annotate("occulted by\nmountains", xy=(22, 1000), xytext=(21, 3000),
         arrowprops=Dict(:width=>1, :headwidth=>5, :headlength=>5,
                         :shrink=>0.05, :facecolor=>"black"),
         horizontalalignment="right",
         fontsize=12)

subplot(1, 2, 2)
gca()[:tick_params](axis="both", which="major", labelsize=12)
plot_light_curve( 4, 2, ".", "#d62728", "36.528 MHz")
plot_light_curve(18, 2, ".", "#1f77b4", "73.152 MHz")
text(0.95, 0.95, names[4][2],
     transform=gca()[:transAxes], fontsize=14, fontweight="bold",
     horizontalalignment="right", verticalalignment="top",
     color="black", zorder=2)
#legend("upper right")
text(0.95, 0.86, "36.528 MHz",
     transform=gca()[:transAxes], fontsize=12, fontweight="bold",
     horizontalalignment="right", verticalalignment="top",
     color="#d62728", zorder=2)
text(0.95, 0.77, "73.152 MHz",
     transform=gca()[:transAxes], fontsize=12, fontweight="bold",
     horizontalalignment="right", verticalalignment="top",
     color="#1f77b4", zorder=2)
xlim(0, 28)
ylim(0, 35000)
xlabel("time from start of observation (hours)", fontsize=12)

tight_layout()

savefig(joinpath(path, "scintillation.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

