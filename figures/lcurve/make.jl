using JLD, PyPlot

path = dirname(@__FILE__)
trials, regnorm, lsnorm = load(joinpath(path, "lcurve.jld"), "trials", "regnorm", "lsnorm")

close("all")
figure(1, figsize=(6, 4))
plot(regnorm, lsnorm, "k-")
for idx = 8:7:36
    annotate(@sprintf("ε=%g", trials[idx]), xy=(regnorm[idx], lsnorm[idx]),
             xytext=(regnorm[idx]+60000, lsnorm[idx]+20000),
             arrowprops=Dict(:width=>1, :headwidth=>5, :headlength=>5,
                             :shrink=>0.05, :facecolor=>"black"))
end
xlabel(L"\Vert a \Vert", fontsize=12)
ylabel(L"\Vert v - Ba \Vert", fontsize=12)
tight_layout()

savefig(joinpath(path, "lcurve.pdf"), bbox_inches="tight", pad_inches=0.1, transparent=true)

