#!/usr/bin/env julia

cd(@__DIR__)
dir = "eastwood-ovro-sky-maps"
isdir(dir) && rm(dir, recursive=true)
mkdir(dir)
mkdir(joinpath(dir, "figures"))

base_files = ["aasjournal.bst", "aastex61.cls", "paper.bib", "paper.tex"]
foreach(file->cp(file, joinpath(dir, file)), base_files)

lines = readlines("paper.tex")
figures = String[]
for line in lines
    m = match(r"figures\/(.*)\/(.*)}", line)
    if m !== nothing
        push!(figures, joinpath("figures", m.captures[1], m.captures[2]))
    end
end

for figure in figures
    if !endswith(figure, ".pdf")
        figure = figure*".pdf"
    end
    @show figure
    mydir = joinpath(dir, dirname(figure))
    isdir(mydir) || mkdir(mydir)
    cp(figure, joinpath(dir, figure))
end

run(`tar -cvf eastwood-ovro-sky-maps.tar $dir`)

