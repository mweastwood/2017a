using JLD, PyPlot

path = dirname(@__FILE__)
close("all")

function plot(filename)
    img = load(joinpath(path, filename*".jld"), "img")
    img = img[51:151, 51:151]
    img /= maximum(img)
    
    figure()
    gca()[:tick_params](axis="both", which="major", labelsize=16)
    
    imshow(img.', interpolation="nearest", cmap=get_cmap("magma"),
           vmin=-0.2, vmax=1.0,
           extent=(150, -150, -150, 150))
    gca()[:set_aspect]("equal")
    cbar = colorbar()
    cbar[:ax][:tick_params](labelsize=16)
    xlabel("ΔRA" * " (arcmin)", fontsize=16)
    ylabel("Δdec" * " (arcmin)", fontsize=16)
    tight_layout()

    savefig(joinpath(path, filename*".pdf"),
            bbox_inches="tight", pad_inches=0.1, transparent=true)
end

#plot("spw04-psf-00-degrees")
plot("spw04-psf-45-degrees")

