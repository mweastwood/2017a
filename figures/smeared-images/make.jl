using FileIO, Images, Colors, FITSIO, WCS

# Note: The version of Imagemagick is doing some weird stuff with its gray scale. I think the colors
# are non-linear with gamma = 0.4545 according to this forum post:
# http://www.imagemagick.org/discourse-server/viewtopic.php?f=4&t=21269
#
# Alternatively we can just import a color map because the RGB images don't seem to have this
# problem.

# $ convert --version
# Version: ImageMagick 6.7.7-10 2012-07-05 Q16 http://www.imagemagick.org
# Copyright: Copyright (C) 1999-2012 ImageMagick Studio LLC
# Features: OpenMP

path = dirname(@__FILE__)
magma = readcsv(joinpath(path, "..", "magma.csv"))
values = linspace(0, 1, size(magma, 1))

function process(filename)
    fits = FITS(joinpath(path, "raw", filename))
    img = read(fits[1])[:, :, 1, 1]
    header = read_header(fits[1])
    
    output = zeros(RGBA{N0f8}, size(img))
    
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
    
    max_value = 4e5
    min_value = -3e5
    
    img -= min_value
    img /= max_value - min_value
    img = clamp.(img, 0, 1)
    x1 = x2 = round(Int, crpix[1])
    y1 = y2 = round(Int, crpix[2])
    for jdx = 1:size(img, 2), idx = 1:size(img, 1)
        if hypot(idx-crpix[1], jdx-crpix[2]) < radius + 5
            value = img[idx, jdx]#^0.4545 # correct for gamma
            # linearly interpolate the color map
            index = searchsortedlast(values, value)
            if index == 0
                r = magma[1, 1]
                g = magma[1, 2]
                b = magma[1, 3]
            elseif index == length(values)
                r = magma[index, 1]
                g = magma[index, 2]
                b = magma[index, 3]
            else
                weight1 = 1 - (value - values[index])/(values[index+1] - values[index])
                weight2 = 1 - weight1
                r = weight1*magma[index, 1] + weight2*magma[index+1, 1]
                g = weight1*magma[index, 2] + weight2*magma[index+1, 2]
                b = weight1*magma[index, 3] + weight2*magma[index+1, 3]
            end
            output[idx, jdx] = RGBA(r, g, b, 1)
            x1 = min(x1, idx)
            x2 = max(x2, idx)
            y1 = min(y1, idx)
            y2 = max(y2, idx)
        end
    end
    output = output[x1:x2, y1:y2]
    
    output_path = joinpath(path, replace(filename, ".fits", ".png"))
    save(output_path, flipdim(output.', 1))
    run(`convert $output_path -resize 512x512 $output_path`)
end

process("pickup-like-component-spw14.fits")
process("rfi-like-component-spw14.fits")
process("after-component-removal-spw14.fits")
process("before-component-removal-spw14.fits")

