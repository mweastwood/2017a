using JLD, PyPlot

path = dirname(@__FILE__)
trials, regnorm, lsnorm = load(joinpath(path, "lcurve.jld"), "trials", "regnorm", "lsnorm")
regnorm /= 10000
lsnorm  /= 10000

function do_annotation(idx, x, y)
    annotate(@sprintf("ε=%g", trials[idx]), xy=(regnorm[idx], lsnorm[idx]),
             xytext=(regnorm[idx]+x, lsnorm[idx]+y),
             arrowprops=Dict(:width=>1, :headwidth=>5, :headlength=>5,
                             :shrink=>0.05, :facecolor=>"black"),
             horizontalalignment=x≤0 ? "center" : "left",
             fontsize=16)
end


close("all")
figure(1)

gca()[:tick_params](axis="both", which="major", labelsize=16)
plot(regnorm, lsnorm, "k-")
do_annotation(8, 10, 10)
do_annotation(15, 10, 10)
do_annotation(22, 10, 10)
do_annotation(29, 0, 10)
do_annotation(36, 10, 10)
xlabel(L"\Vert a \Vert" * " (arbitrary units)", fontsize=16)
ylabel(L"\Vert v - Ba \Vert" * " (arbitrary units)", fontsize=16)
tight_layout()

savefig(joinpath(path, "lcurve.pdf"), bbox_inches="tight", pad_inches=0.1, transparent=true)

