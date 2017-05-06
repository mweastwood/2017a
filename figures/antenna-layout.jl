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
rc("text", usetex=false)
rc("font", weight="light")
rc("axes", labelweight="light", linewidth=1.5)
rc("xtick", labelsize=14)
rc("ytick", labelsize=14)

#close("all")
figure(1, figsize=(6, 5)); clf()

scatter(east[core], north[core], c="k", s=10, lw=0)
scatter(east[leda], north[leda], marker="+", c="k", s=100, lw=1.5)
scatter(east[expansion], north[expansion], marker="o", c=transparent, s=50, lw=1.5)
xticks(collect(-1500:500:500))
yticks(collect(-500:500:1000))
xlim(-1250, 500)
ylim(-500, 1000)
gca()[:set_aspect]("equal")
#gca()[:spines]["top"][:set_visible](false)
#gca()[:spines]["right"][:set_visible](false)
#gca()[:get_xaxis]()[:tick_bottom]()
#gca()[:get_yaxis]()[:tick_left]()
gca()[:get_xaxis]()[:set_tick_params](width=1.5, size=5)
gca()[:get_yaxis]()[:set_tick_params](width=1.5, size=5)
grid("off")
xlabel("distance east / m", fontsize=16)
ylabel("distance north / m", fontsize=16)
tight_layout()

savefig("antenna-layout.pdf", bbox_inches="tight", pad_inches=0.1, transparent=true)

