using PyPlot

matrix = readdlm("antenna-layout.txt");
east = matrix[:,1]
north = matrix[:,2]
up = matrix[:,3]
east -= 2

core = 1:251
leda = 252:256
expansion = 257:288

transparent = (0, 0, 0, 0)
figure(1, figsize=(6, 5)); clf()

scatter(east[core], north[core], marker="o", c="k", s=8, lw=0)
scatter(east[leda], north[leda], marker="+", c="k", s=50)
scatter(east[expansion], north[expansion], marker="^", c="k", s=20)
gca()[:set_aspect]("equal")
xlabel("distance east / m", fontsize=12)
ylabel("distance north / m", fontsize=12)
tight_layout()

savefig("antenna-layout.pdf", bbox_inches="tight", pad_inches=0.1, transparent=true)

