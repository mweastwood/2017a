using LibHealpix, PyPlot, PyCall

unshift!(PyVector(pyimport("sys")["path"]), "")
@pyimport my_log_scale as mls

path = dirname(@__FILE__)
close("all")

const c = 2.99792e8 # m/s
const k = 1.38065e-23 # J/K
const Jy = 1e-26 # one Jansky in mks units

# Jackknife variance estimator
# https://en.wikipedia.org/wiki/Jackknife_resampling#Variance_estimation

function plot(combined, odd, even, ν)
    combined_map = readhealpix(joinpath(path, combined))
    odd_map  = readhealpix(joinpath(path, odd))
    even_map = readhealpix(joinpath(path, even))

    λ = c/ν
    factor = Jy*λ^2/(2k)
    combined_map = combined_map .* factor
    odd_map  =  odd_map .* factor
    even_map = even_map .* factor

    variance = 0.5 .* ((odd_map - combined_map).^2 .+ (even_map .- combined_map).^2)
    standard_deviation = sqrt.(variance)
    @show median(standard_deviation)

    img = mollweide(standard_deviation)
    max = maximum(img)/10
    min = minimum(img)
    base = max - min

    figure(); clf()
    gca()[:tick_params](axis="both", which="major", labelsize=16)
    θ = linspace(0, 2π, 512)
    x = 2cos.(θ)
    y = sin.(θ)
    ellipse = plt[:Polygon]([x y], alpha=0)
    gca()[:add_patch](ellipse)
    imshow(img, interpolation="nearest", cmap=get_cmap("magma"),
           norm = mls.MyLogNormalize(min, max, base),
           extent=(-2, 2, -1, 1),
           clip_path=ellipse)
    gca()[:set_aspect]("equal")
    title(@sprintf("%.3f MHz", ν/1e6), fontsize=16)
    axis("off")
    cbar = colorbar(fraction=0.02)
    cbar[:ax][:tick_params](labelsize=16)
    tight_layout()

    savefig(joinpath(path, replace(combined, ".fits", ".pdf")),
            bbox_inches="tight", pad_inches=0, transparent=true)
end

plot("4.fits", "4-odd.fits", "4-even.fits", 36.528e6)
plot("6.fits", "6-odd.fits", "6-even.fits", 41.760e6)
plot("8.fits", "8-odd.fits", "8-even.fits", 46.992e6)
plot("10.fits", "10-odd.fits", "10-even.fits", 52.224e6)
plot("12.fits", "12-odd.fits", "12-even.fits", 57.456e6)
plot("14.fits", "14-odd.fits", "14-even.fits", 62.688e6)
plot("16.fits", "16-odd.fits", "16-even.fits", 67.920e6)
plot("18.fits", "18-odd.fits", "18-even.fits", 73.152e6)

