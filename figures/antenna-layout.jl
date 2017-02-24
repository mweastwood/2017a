using PyPlot

matrix = readdlm("antenna-layout.txt");
east = matrix[:,1];
north = matrix[:,2];
up = matrix[:,3];
east -= 2

core = 1:251
leda = 252:256
expansion = 257:288

θ = linspace(0, 2π, 1000)
circlex = 110sin(θ)
circley = 110cos(θ)

transparent = (0, 0, 0, 0)
rc("xtick", labelsize=16)
rc("ytick", labelsize=16)

figure(1, figsize=(6,6)); clf()

#subplot(1,2,1)
scatter(east[leda], north[leda], c=transparent, s=30, lw=2)
scatter(east[expansion], north[expansion], c="k", s=30, lw=2)
plot(circlex, circley, "k--", lw=2)
xticks(collect(-1250:250:500))
yticks(collect(-500:250:1000))
xlim(-1250, 500)
ylim(-625, 1125)
gca()[:set_aspect]("equal")
gca()[:spines]["top"][:set_visible](false)
gca()[:spines]["right"][:set_visible](false)
gca()[:get_xaxis]()[:tick_bottom]()
gca()[:get_yaxis]()[:tick_left]()
grid("off")
xlabel("distance east / meters", fontsize=16)
ylabel("distance north / meters", fontsize=16)
tight_layout()

#subplot(1,2,2)
#scatter(east, north, c="k", s=50, lw=0)
#plot(circlex, circley, "k--", lw=2)
#xticks(collect(-150:50:150))
#yticks(collect(-150:50:150))
#xlim(-125, 125)
#ylim(-125, 125)
#gca()[:set_aspect]("equal")
#gca()[:spines]["top"][:set_visible](false)
#gca()[:spines]["right"][:set_visible](false)
#gca()[:get_xaxis]()[:tick_bottom]()
#gca()[:get_yaxis]()[:tick_left]()
#grid("off")
#xlabel("distance east / meters", fontsize=24)
#ylabel("distance north / meters", fontsize=24)
#tight_layout()

savefig("antenna-layout.pdf", bbox_inches="tight", pad_inches=0, transparent=true)

