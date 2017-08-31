#!/usr/bin/env julia

using JLD, PyPlot, CasaCore.Measures

path = dirname(@__FILE__)
figure(1, figsize=(12, 6)); clf()

names, t, δra, δdec, flags = load(joinpath(path, "refraction-curves-rainy.jld"),
                                  "names", "t", "dra", "ddec", "flags")

function plot_ra(spw, src, color)
    f = flags[spw][src, :]
    x = copy(t[spw])
    y = δra[spw][src, :]
    x -= x[1]
    x /= 3600
    y = 60rad2deg.(y)
    x[f] = NaN
    y[f] = NaN
    plot(x, y, "-", color=color, lw=1)
end

function plot_dec(spw, src, color)
    f = flags[spw][src, :]
    x = copy(t[spw])
    y = δdec[spw][src, :]
    x -= x[1]
    x /= 3600
    y = 60rad2deg.(y)
    x[f] = NaN
    y[f] = NaN
    plot(x, y, "-", color=color, lw=1)
end

subplot(2, 2, 1)
gca()[:tick_params](axis="both", which="major", labelsize=12)
axhline(0, c="0.75", lw=1)
plot_ra( 4, 1, "#d62728")
plot_ra(18, 1, "#1f77b4")
xlim(0, 28)
ylim(-25, 25)
ylabel("ΔRA (arcmin)", fontsize=12)
plt[:setp](gca()[:get_xticklabels](), visible=false)
text(0.05, 0.95, "Cyg A",
     transform=gca()[:transAxes], fontsize=14, fontweight="bold",
     horizontalalignment="left", verticalalignment="top",
     color="black", zorder=2)

subplot(2, 2, 2)
gca()[:tick_params](axis="both", which="major", labelsize=12)
axhline(0, c="0.75", lw=1)
plot_ra( 4, 2, "#d62728")
plot_ra(18, 2, "#1f77b4")
xlim(0, 28)
ylim(-25, 25)
plt[:setp](gca()[:get_xticklabels](), visible=false)
text(0.05, 0.95, "Cas A",
     transform=gca()[:transAxes], fontsize=14, fontweight="bold",
     horizontalalignment="left", verticalalignment="top",
     color="black", zorder=2)

subplot(2, 2, 3)
gca()[:tick_params](axis="both", which="major", labelsize=12)
axhline(0, c="0.75", lw=1)
plot_dec( 4, 1, "#d62728")
plot_dec(18, 1, "#1f77b4")
xlim(0, 28)
ylim(-25, 25)
xlabel("time from start of observation (hours)", fontsize=12)
ylabel("Δdec (arcmin)", fontsize=12)

subplot(2, 2, 4)
gca()[:tick_params](axis="both", which="major", labelsize=12)
axhline(0, c="0.75", lw=1)
plot_dec( 4, 2, "#d62728")
plot_dec(18, 2, "#1f77b4")
xlim(0, 28)
ylim(-25, 25)
xlabel("time from start of observation (hours)", fontsize=12)

tight_layout()
gcf()[:subplots_adjust](hspace=0)

savefig(joinpath(path, "refraction.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

