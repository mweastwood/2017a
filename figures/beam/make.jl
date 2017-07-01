using JLD, PyPlot, CasaCore.Measures

path = dirname(@__FILE__)
Iimg = load(joinpath(path, "beam.jld"), "I-image")

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

close("all")
figure(1, figsize=(6, 4))
circle = plt[:Circle]((0, 0), 1, alpha=0)
gca()[:add_patch](circle)
imshow(Iimg, extent=(-1, 1, -1, 1), interpolation="nearest", vmin=0, vmax=1,
       cmap=get_cmap("magma"), clip_path=circle)
gca()[:set_aspect]("equal")
colorbar()
xlim(-1, 1)
ylim(-1, 1)
xlabel("l / direction cosine", fontsize=12)
ylabel("m / direction cosine", fontsize=12)
tight_layout()
savefig(joinpath(path, "stokes-I-beam.pdf"), bbox_inches="tight", pad_inches=0.1, transparent=true)

figure(2, figsize=(6, 4)); clf()
frame = ReferenceFrame()
set!(frame, ovro_lwa)
for name in keys(sources)
    @show name
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
    annotate(name, xy=(0, mmin+0.01), horizontalalignment="center")
    plot(l, m, "k-")
end
θ = linspace(0, 2π, 1000)
annotate("Horizon", xy=(0, -0.98), horizontalalignment="center")
plot(cos.(θ), sin.(θ), "k--")
gca()[:set_aspect]("equal")
xlim(-1, 1)
ylim(-1, 1)
xlabel("l / direction cosine", fontsize=12)
ylabel("m / direction cosine", fontsize=12)
tight_layout()
savefig(joinpath(path, "source-tracks.pdf"), bbox_inches="tight", pad_inches=0.1, transparent=true)

# We need to add some extra width to this figure to make it match the previous one.
# Note: use `pdfinfo filename.pdf` to get the size of each file before modifying this.

run(`pdfcrop stokes-I-beam.pdf stokes-I-beam.pdf`) # remove extra whitespace
run(`pdfcrop source-tracks.pdf source-tracks.pdf`) # remove extra whitespace
run(`pdfcrop --margins '0 0 46 0' source-tracks.pdf source-tracks.pdf`) # add margin on the right

