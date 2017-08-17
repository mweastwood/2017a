#!/usr/bin/env julia

using JLD, PyPlot, CasaCore.Measures

path = dirname(@__FILE__)
figure(1, figsize=(15, 5)); clf()

# Create the source track panel

sources = Dict("Cyg A" => Direction(dir"J2000", "19h59m28.35663s", "+40d44m02.0970s"),
               "Cas A" => Direction(dir"J2000", "23h23m24.000s", "+58d48m54.00s"),
               "Tau A" => Direction(dir"J2000", "05h34m31.94s", "+22d00m52.2s"),
               "Vir A" => Direction(dir"J2000", "12h30m49.42338s", "+12d23m28.0439s"),
               "Her A" => Direction(dir"J2000", "16h51m11.4s", "+04d59m20s"),
               "Hya A" => Direction(dir"J2000", "09h18m05.651s", "-12d05m43.99s"),
               "Per B" => Direction(dir"J2000", "04h37m04.3753s", "+29d40m13.819s"),
               "3C 353" => Direction(dir"J2000", "17h20m28.147s", "-00d58m47.12s"))

ovro_lwa = Position(pos"ITRF", -2.40927462614919e6, -4.477838733582964e6, 3.839370728766106e6)

times = linspace(4.994049600941745e9, 4.994150416022397e9, 7756)

subplot(1, 3, 1)
frame = ReferenceFrame()
set!(frame, ovro_lwa)
for name in keys(sources)
    direction = sources[name]
    l = Float64[]
    m = Float64[]
    for t in times
        set!(frame, Epoch(epoch"UTC", t*seconds))
        azel = measure(frame, direction, dir"AZEL")
        az = longitude(azel)
        el =  latitude(azel)
        if el > 0
            push!(l, sin(az)*cos(el))
            push!(m, cos(az)*cos(el))
        else
            push!(l, NaN)
            push!(m, NaN)
        end
    end
    mmin = minimum(m[.!isnan.(m)])
    if name == "3C 353"
        annotate(name, xy=(0, mmin+0.01), horizontalalignment="center",
                 fontsize=12)
    else
        annotate(name, xy=(0, mmin+0.02), horizontalalignment="center",
                 fontsize=12)
    end
    plot(l, m, "k-")
end
θ = linspace(0, 2π, 1000)
annotate("Horizon", xy=(0, -0.98), horizontalalignment="center",
         fontsize=12)
gca()[:tick_params](axis="both", which="major", labelsize=15)
plot(cos.(θ), sin.(θ), "k--")
gca()[:set_aspect]("equal")
xlim(1, -1)
ylim(-1, 1)
xlabel("l (direction cosine)", fontsize=15)
ylabel("m (direction cosine)", fontsize=15)

# Create the beam panels

frequencies = [3.6528e7, 7.3152e7]
filenames = ["spw04-beam", "spw18-beam"]

global _im
for idx = 1:length(filenames)
    subplot(1, 3, idx+1)
    filename = filenames[idx]

    img = load(joinpath(path, filename*".jld"), "I-image")
    
    gca()[:tick_params](axis="both", which="major", labelsize=15)
    
    circle = plt[:Circle]((0, 0), 1, alpha=0)
    gca()[:add_patch](circle)
    _im = imshow(img, extent=(-1, 1, -1, 1), interpolation="nearest", vmin=0, vmax=1,
                 cmap=get_cmap("magma"), clip_path=circle)
    gca()[:set_aspect]("equal")
    xlim(1, -1)
    ylim(-1, 1)
    plt[:setp](gca()[:get_yticklabels](), visible=false)
    xlabel("l (direction cosine)", fontsize=15)
    txt = text(0.95, 0.95, @sprintf("%.3f MHz", frequencies[idx]/1e6),
               transform=gca()[:transAxes], fontsize=18, fontweight="bold",
               horizontalalignment="right", verticalalignment="top",
               color="black", zorder=2)
    txt[:set_bbox](Dict(:facecolor=>"white", :alpha=>0.5, :edgecolor=>"none"))
end

gcf()[:subplots_adjust](wspace=0.10)

cax = gcf()[:add_axes]([0.92, 0.13, 0.023, 0.73])
cbar = colorbar(_im, cax=cax)
cbar[:ax][:tick_params](labelsize=15)
cbar[:set_label]("normalized amplitude", fontsize=15, rotation=270)
cbar[:ax][:get_yaxis]()[:set_label_coords](3.3, 0.5)

savefig(joinpath(path, "beam.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

