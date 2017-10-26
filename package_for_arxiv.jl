#!/usr/bin/env julia

cd(@__DIR__)
dir = "arxiv"
isdir(dir) && rm(dir, recursive=true)
mkdir(dir)

run(`make`)

base_files = ["aasjournal.bst", "aastex61.cls", "paper.bbl"]
foreach(file->cp(file, joinpath(dir, file)), base_files)

lines = readlines("paper.tex", chomp=false)
file = open(joinpath(dir, "paper.tex"), "w")
figures = String[]
for line in lines
    m = match(r"figures\/(.*)\/(.*)}", line)
    if m !== nothing
        subdir = m.captures[1]
        figure = m.captures[2]
        line = replace(line, "figures/$subdir/$figure", figure)
        push!(figures, joinpath("figures", subdir, figure))
    end
    write(file, line)
end
close(file)

for figure in figures
    if !endswith(figure, ".pdf")
        figure = figure*".pdf"
    end
    @show figure
    cp(figure, joinpath(dir, basename(figure)))
end

run(`tar -cvf $dir.tar $dir`)
rm(dir, recursive=true)

# Print the abstract in the right format
abstract_start = 0
abstract_stop  = 0
for (number, line) in enumerate(lines)
    if contains(line, "begin{abstract}")
        abstract_start = number
    end
    if contains(line, "end{abstract}")
        abstract_stop = number
        break
    end
end

abstract_text = lines[abstract_start+1:abstract_stop-1]
abstract_text = strip.(abstract_text)
abstract_text = join(abstract_text, " ")
abstract_text = replace(abstract_text, "~", " ")

println("Abstract")
println("========")
println(abstract_text)

