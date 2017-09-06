#!/usr/bin/env julia

using JLD, PyPlot, PyCall, FITSIO, WCS, LibHealpix

@pyimport mpl_toolkits.axes_grid1 as tk
@pyimport matplotlib.gridspec as gridspec

path = dirname(@__FILE__)

figure(1, figsize=(12, 5)); clf()

function decide_on_color_scale(img, f=0.9)
    img ./= maximum(img)
    pixels = vec(img)
    pixels = pixels[pixels .!= 0]
    pixels = abs.(pixels)
    sort!(pixels)
    N = length(pixels)
    scale = pixels[round(Int, f*N+1)]
    scale
end

map1 = readhealpix(joinpath(path, "map-rfi-restored-peeled-rainy-2048-galactic.fits"))
map2 = readhealpix(joinpath(path, "map-rfi-subtracted-peeled-rainy-2048-galactic.fits"))
δ = map2-map1
img = mollweide(δ, (2048, 4096))
scale = decide_on_color_scale(img)

θ = linspace(0, 2π, 512)
x = 2cos.(θ)
y = sin.(θ)

ellipse = plt[:Polygon]([x y], alpha=0)
gca()[:add_patch](ellipse)
imshow(img, interpolation="nearest", cmap=get_cmap("magma"),
       vmin=-scale, vmax=+scale,
       extent=(-2, 2, -1, 1),
       clip_path=ellipse, zorder=10)
xlim(-2, 2)
ylim(-1, 1)
gca()[:set_aspect]("equal")
gca()[:get_xaxis]()[:set_visible](false)
gca()[:get_yaxis]()[:set_visible](false)
axis("off")

#txt = text(0.01, 0.98, "(d)",
#           transform=gca()[:transAxes], fontsize=14, fontweight="bold",
#           horizontalalignment="left", verticalalignment="top",
#           color="black", zorder=2)

cbar = colorbar()
cbar[:ax][:tick_params](labelsize=12)
cbar[:set_label]("normalized amplitude", fontsize=12, rotation=270)
cbar[:ax][:get_yaxis]()[:set_label_coords](4.5, 0.5)

tight_layout()

savefig(joinpath(path, "rings.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

figure(2, figsize=(12, 4)); clf()

function plot_fits(filename)
    fits = FITS(joinpath(path, filename))
    img = read(fits[1])[:, :, 1, 1]
    header = read_header(fits[1])
    
    naxis = 2
    equinox = header["EQUINOX"]
    ctype =  String[header["CTYPE1"], header["CTYPE2"]]
    crpix = Float64[header["CRPIX1"], header["CRPIX2"]]
    crval = Float64[header["CRVAL1"], header["CRVAL2"]]
    cdelt = Float64[header["CDELT1"], header["CDELT2"]]
    cunit =  String[header["CUNIT1"], header["CUNIT2"]]
    wcs = WCSTransform(naxis, equinox=equinox, ctype=ctype, crpix=crpix,
                       crval=crval, cdelt=cdelt, cunit=cunit)
    
    center_ra, center_dec = crval[1], crval[2]
    south_ra = center_ra
    south_dec = center_dec - 90
    south_pixcoords = world_to_pix(wcs, reshape([south_ra, south_dec], (2, 1)))
    radius = hypot(crpix[1] - south_pixcoords[1], crpix[2] - south_pixcoords[2])
    
    x1 = x2 = round(Int, crpix[1])
    y1 = y2 = round(Int, crpix[2])
    for jdx = 1:size(img, 2), idx = 1:size(img, 1)
        if hypot(idx-crpix[1], jdx-crpix[2]) < radius + 10
            x1 = min(x1, idx)
            x2 = max(x2, idx)
            y1 = min(y1, idx)
            y2 = max(y2, idx)
        else
            img[idx, jdx] = 0
        end
    end
    img = img[x1:x2, y1:y2]
    scale = decide_on_color_scale(img, 0.999)
    
    θ = linspace(0, 2π, 512)
    x = cos.(θ)
    y = sin.(θ)

    ellipse = plt[:Polygon]([x y], alpha=0)
    gca()[:add_patch](ellipse)
    _im = imshow(flipdim(img.', 1), interpolation="nearest", cmap=get_cmap("magma"),
                 #vmin=-scale, vmax=+scale,
                 vmin=-0.4, vmax=+0.4,
                 extent=(1, -1, -1, 1),
                 clip_path=ellipse, zorder=10)
    xlim(1, -1)
    ylim(-1, 1)
    _im
end

#plot_fits("fitrfi-test-start-rfi-restored-peeled-rainy.fits")
#plot_fits("fitrfi-test-finish-rfi-restored-peeled-rainy.fits")
#plot_fits("fitrfi-rfi-restored-peeled-rainy-1.fits")
#plot_fits("fitrfi-rfi-restored-peeled-rainy-2.fits")
#plot_fits("fitrfi-rfi-restored-peeled-rainy-3.fits")

ax = gca()
divider = tk.make_axes_locatable(ax)

_im = plot_fits("fitrfi-rfi-restored-peeled-rainy-1.fits")
xlabel("l (direction cosine)", fontsize=12)
ylabel("m (direction cosine)", fontsize=12)
xticks([1.0, 0.5, 0.0, -0.5])
yticks([1.0, 0.5, 0.0, -0.5, -1.0])
txt = text(0.01, 0.98, "(a)",
           transform=gca()[:transAxes], fontsize=14, fontweight="bold",
           horizontalalignment="left", verticalalignment="top",
           color="black", zorder=2)

_ax = divider[:append_axes]("right", size="100%", pad=0.1)
_im = plot_fits("fitrfi-rfi-restored-peeled-rainy-2.fits")
xlabel("l (direction cosine)", fontsize=12)
plt[:setp](gca()[:get_yticklabels](), visible=false)
xticks([1.0, 0.5, 0.0, -0.5])
yticks([1.0, 0.5, 0.0, -0.5, -1.0])
txt = text(0.01, 0.98, "(b)",
           transform=gca()[:transAxes], fontsize=14, fontweight="bold",
           horizontalalignment="left", verticalalignment="top",
           color="black", zorder=2)

_ax = divider[:append_axes]("right", size="100%", pad=0.1)
_im = plot_fits("fitrfi-rfi-restored-peeled-rainy-3.fits")
xlabel("l (direction cosine)", fontsize=12)
plt[:setp](gca()[:get_yticklabels](), visible=false)
xticks([1.0, 0.5, 0.0, -0.5, -1.0])
yticks([1.0, 0.5, 0.0, -0.5, -1.0])
txt = text(0.01, 0.98, "(c)",
           transform=gca()[:transAxes], fontsize=14, fontweight="bold",
           horizontalalignment="left", verticalalignment="top",
           color="black", zorder=2)

cax = divider[:append_axes]("right", size="5%", pad=0.10)
cbar = colorbar(_im, cax=cax)
cbar[:ax][:tick_params](labelsize=12)
cbar[:set_label]("normalized amplitude", fontsize=12, rotation=270)
cbar[:ax][:get_yaxis]()[:set_label_coords](5.5, 0.5)

tight_layout()

savefig(joinpath(path, "smeared.pdf"),
        bbox_inches="tight", pad_inches=0, transparent=true)

