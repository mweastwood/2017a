#!/usr/bin/env julia

using JLD, PyPlot, CasaCore.Measures

path = dirname(@__FILE__)
figure(1, figsize=(6, 4)); clf()

utc, vobs, north_vobs, south_vobs = load(joinpath(path, "ionosphere.jld"), "utc", "vobs",
                                         "north_vobs", "south_vobs")
utc -= 12

# find sunrise and sunset
sun = Direction(dir"SUN")
ovro_lwa = Position(pos"ITRF", -2.40927462614919e6, -4.477838733582964e6, 3.839370728766106e6)
times = linspace(4.994049600941745e9, 4.994150416022397e9, 7756)

frame = ReferenceFrame()
set!(frame, ovro_lwa)
elevation = zeros(length(times))
for idx = 1:length(times)
    set!(frame, Epoch(epoch"UTC", times[idx]*seconds))
    azel = measure(frame, sun, dir"AZEL")
    elevation[idx] = latitude(azel)
end
sunrise = Float64[]
sunset = Float64[]
for idx = 1:length(times)-1
    if elevation[idx] ≤ 0 && elevation[idx+1] > 0
        push!(sunrise, (times[idx]-times[1])/3600)
    elseif elevation[idx] > 0 && elevation[idx+1] ≤ 0
    push!(sunset, (times[idx]-times[1])/3600)
    end
end

plot(utc, vobs, "k-", label="all receivers")
#plot(utc, north_vobs, "-", c="C0", label="north of OVRO")
#plot(utc, south_vobs, "-", c="C1", label="south of OVRO")
axvspan(minimum(utc), 0, alpha=0.15, color="black")
axvspan(28, maximum(utc), 0, alpha=0.15, color="black")
for t in sunrise
    axvline(t, lw=1, color="0.75", zorder=0)
    annotate("sunrise", xy=(t, 0.3), fontsize=12,
             horizontalalignment="right",
             verticalalignment="bottom",
             rotation=90)
end
for t in sunset
    axvline(t, lw=1, color="0.75", zorder=0)
    annotate("sunset", xy=(t, 0.3), fontsize=12,
             horizontalalignment="right",
             verticalalignment="bottom",
             rotation=90)
end

gca()[:tick_params](axis="both", which="major", labelsize=13)
xlabel("time from start of observation (hours)", fontsize=13)
ylabel("median vertical TEC (TECU)", fontsize=13)
xlim(minimum(utc), maximum(utc))
ylim(0, 23)
#legend(fontsize=12, loc="upper left")
tight_layout()

savefig(joinpath(path, "vtec.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

