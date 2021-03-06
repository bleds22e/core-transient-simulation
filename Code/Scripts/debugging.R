## This script is used to debug the Core-Transient Simulation


sim_dir = 'C:/Users/jrcoyle/Documents/Research/CT-Sim/GitHub/Code/'
run_dir = 'C:/Users/jrcoyle/Documents/Research/CT-Sim/Runs/'
parm_dir = 'C:/Users/jrcoyle/Documents/Research/CT-Sim/GitHub/Code/'


source(file.path(sim_dir, 'simulation_functions.R'))

setwd('C:/Users/jrcoyle/Documents/Research/CT-Sim/')

## Testing run_sim_N function
# Read in parameters
parm_file = file.path(parm_dir, 'p_run3.txt')
source(parm_file)
parm_list = make_parmlist()

# Run CAMM
sim_results = run_sim_N(3, parm_list, 1, simID, sim_dir=sim_dir, report=5, return_results=T, restart=F)



## Testing summary functions from runs saved seapartely.
simID = 'converge32'
scale_locs = sapply(2^c(0:4), function(fact) aggregate_cells(X=c(32,32), dX=fact, dY=fact, form='partition'))

sim = file.path(run_dir, 'converge32_d-9', paste0(simID, '_run1.RData'))
locs = scale_locs[[3]]
t_window=list(start=975, stop=1000)
P_obs = list(1,.9,.5,.1)
breaks=c(.33, .66)
sum_parms=list(time_sum='last', quants=c(0.025, .5, .975))

sim_sum = summarize_sim(sim, breaks, locs=locs, t_window=t_window, P_obs=P_obs, sum_parms=sum_parms) 

sim = file.path(run_dir, simID)


sapply(1:5, function(i) summarize_land(sim, scale_locs[[i]]))

# Check landscapes
sim = file.path(run_dir, 'converge32_d-9', paste0(simID, '_run2.RData'))
load(sim)
plot(this_land)

## Testing summary functions
load('C:/Users/jrcoyle/Documents/Research/CT-Sim/GitHub/Results/run1.RData')

# locations from the center of the grid- NOT WORKING
scale_locs = sapply(2^c(0:2), function(fact){
	aggregate_cells(X=c(16,16), dX=fact, dY=fact, form='origin', locs=expand.grid(x=c(4,12), y=c(4,12)))
})

# locations are a partition of the grid
scale_locs = sapply(2^c(0:3), function(fact) aggregate_cells(X=c(16,16), dX=fact, dY=fact, form='partition'))


nruns = 3 

# Examine simulation through time to determine burnin

# Plot species abundances
use_locs = scale_locs[[1]]
abuns = sapply(1:nruns, function(i) calc_abun_profile(use_locs, list(start=0, stop=100), sim_results[[i]], 20), simplify='array')


pdf('abun_profs_scale1_run3.pdf', height=40, width=40) 
par(mfrow=c(16,16))
par(mar=c(2,2,0,0))
par(oma=c(2,2,1,1))
for(i in 1:(16*16)){
	plot_abun_stacked(abuns[,,i,3], sp_type=get_sptype(species_N[[1]][,,'b']), axis_labs=F,
		lform='sp', fill='sp', lcol='black', 
		fillcol=c('darkblue','cyan','green','yellow','orange','red','violet'))
}
dev.off()

pdf('habitat_scale1_run3.pdf', height=4, width=6)
	par(mar=c(2,2,2,5))
	plot(lands_N[[3]], col=c('darkblue','violet'), axes=F)

dev.off()

# Calculate occupancy across sliding time windows of 25 years
t_window = 25
use_times = t_window:100
	
occs_slide = sapply(use_times, function(step){
	use_abuns = abuns[as.character((step-t_window+1):step),,,]
	sapply(1:nruns, function(i) calc_occupancy(abuns=use_abuns[,,,i], do_freq=F), simplify='array')
}, simplify='array')

sptype = get_sptype(species_N[[n]][,,'b'])

# Plot occupancy of each species
hab_cols = c('blue','violet')
names(hab_cols)=c('A','B')

pdf(paste0('occupancy_25yrs_scale1.pdf'), height=40, width=40)
par(mfrow=c(16,16))
par(mar=c(2,2,0,0))
par(oma=c(2,2,1,1))
for(i in 1:(16*16)){
	this_hab = get_habitat(lands_N[[n]][i])

	# Set up plot and axes
	plot.new()
	plot.window(xlim=range(use_times)+c(-.5, .5), ylim=c(0,1)) 

	axis(1)#, at=use_times)
#	abline(h=par('usr')[3], lwd=3)
	axis(2, las=1)
#	abline(v=par('usr')[1], lwd=3)
	box(col=hab_cols[this_hab], lwd=2)
	
	# Lines for each species
	for(sp in 1:length(sptype)){
		lines(use_times, occs_slide[i,sp,n,], col=hab_cols[sptype[sp]], lwd=2)
	}
}

dev.off()


# Plot species richness
occs = sapply(1:nruns, function(i) calc_occupancy(abuns=abuns[as.character(use_steps),,,i], do_freq=F), simplify='array')

tot_rich = calc_rich(abuns=abuns[,,,n])
ct_rich = calc_rich_CT(abuns[,,,n], occs[,,n], breaks=c(0.33,.66))
ab_rich = sapply(c('A','B'), function(x) calc_rich(abuns=abuns[,,,n], which_species = names(which(sptype==x))), simplify='array')

pdf(paste0('richness_scale1.pdf'), height=40, width=40)
par(mfrow=c(16,16))
par(mar=c(2,2,0,0))
par(oma=c(2,2,1,1))
for(i in 1:(16*16)){
	times = 1:nrow(tot_rich)
	this_hab = get_habitat(lands_N[[n]][i])

	# Set up plot and axes
	plot.new()
	plot.window(xlim=c(.5, nrow(tot_rich)+.5), ylim=c(0,length(sptype))) 

	axis(1, at=times, labels=rownames(tot_rich))
#	abline(h=par('usr')[3], lwd=3)
	axis(2, las=1)
#	abline(v=par('usr')[1], lwd=3)
	box(col=hab_cols[this_hab], lwd=2)
		
	# Line for total richness
	lines(times, tot_rich[,i], lwd=3, col='black')
	
	# Lines for richness in occupancy classes
	lines(times, ct_rich[,1,i], lty=5, col='black')
	lines(times, ct_rich[,3,i], lty=1, col='black')

	# Lines for richness in habitat preference classes
	lines(times, ab_rich[,i,'A'], col=hab_cols['A'], lty=ifelse(this_hab=='A', 1, 5), lwd=2)
	lines(times, ab_rich[,i,'B'], col=hab_cols['B'], lty=ifelse(this_hab=='B', 1, 5), lwd=2)	
}
dev.off()



# Average and variance across spatial units
tot_rich_agg = apply(tot_rich, 1, function(x) c(mean(x), var(x)))
rownames(tot_rich_agg) = c('mean','var')

ct_rich_agg = apply(ct_rich, 1:2, function(x) c(mean(x), var(x)))
dimnames(ct_rich_agg)[[1]] = c('mean','var')

ab_rich_agg = apply(ab_rich, c(1,3), function(x) c(mean(x), var(x)))
dimnames(ab_rich_agg)[[1]] = c('mean','var')

# Plot averages and variances through time
use_times = as.numeric(colnames(tot_rich_agg))

plot.new()
plot.window(xlim=range(use_times)+c(-.5, .5), ylim=c(0,length(sptype)))
axis(1)
axis(2, las=1)
box() 

# CIs
draw_ints = function(m, v, use_col){
	up = 1.96*sqrt(v)+m
	down = -1.96*sqrt(v)+m
	xvals = as.numeric(names(m))
	polygon(c(xvals, rev(xvals)), c(up, rev(down)), border=NA, col=use_col)
}

draw_ints(tot_rich_agg['mean',], tot_rich_agg['var',], use_col='#00000050')
draw_ints(ct_rich_agg['mean',,1], ct_rich_agg['var',,1], use_col='#00000050')
draw_ints(ct_rich_agg['mean',,3], ct_rich_agg['var',,3], use_col='#00000050')
draw_ints(ab_rich_agg['mean',,'A'], ab_rich_agg['var',,'A'], use_col='#00000050')
draw_ints(ab_rich_agg['mean',,'B'], ab_rich_agg['var',,'B'], use_col='#00000050')

lines(use_times, tot_rich_agg['mean',], lwd=2)
lines(use_times, ct_rich_agg['mean',,1], lwd=1, lty=5)
lines(use_times, ct_rich_agg['mean',,3], lwd=1, lty=1)
lines(use_times, ab_rich_agg['mean',,'A'], col=hab_cols['A'])
lines(use_times, ab_rich_agg['mean',,'B'], col=hab_cols['B'])


# At each scale
nruns = length(sim_results)
for(s in 1:length(scale_locs)){
	use_locs = scale_locs[[s]]
	
	# Calculate abundance for each run
	abuns = sapply(1:nruns, function(i) calc_abun_profile(use_locs, list(start=75, stop=100), sim_results[[i]], 20), simplify='array')

	# Calculate occupancy
	occs = sapply(1:nruns, function(i) calc_occupancy(abuns=abuns[,,,i], do_freq=F), simplify='array')

	# Cross-classify occupancy vs resident status
	xclass = sapply(1:nruns, function(i){
		b_rates = species_N[[i]][,,'b']
		this_land = lands_N[[i]]
		habitats = sapply(use_locs, function(x) average_habitat(x, this_land))
		cross_classify(occs[,,i], c(0.33, .66), b_rates, habitats, do_each=F, return='counts')
	}, simplify='array')
	

}

# For use when sim_results contains multiple objects (results, lands, species)
abun_profiles = calc_abun_profile(scale_locs[[1]], list(start=75, stop=100), sim_results$results[[1]], 20)
occupancy = calc_occupancy(abuns=abun_profiles, do_freq=F)

b_rates = sim_results$species[[1]][,,'b']
this_land = sim_results$lands[[1]]
habitats = sapply(scale_locs[[1]], function(x) average_habitat(x, this_land))

cross_classify(occupancy, c(.33, .66), b_rates, habitats, do_each=F)




# Load simulation scripts
source(paste0(sim_dir, 'simulation_functions.R'))

# Read in parameters
parm_file = paste0(parm_dir, 'p_runtest.txt')
source(parm_file)
parm_list = make_parmlist()

sim_results = run_sim_N(nruns, parm_list, 1, simID, sim_dir=sim_dir, report=10)

sim_results$results[[1]][1,1,]

abun_profiles = calc_abun_profiles(


# TESTING

nruns = 3
nparallel = 2
simID='test'
sim_dir = 'C:/Users/jrcoyle/Documents/Research/CT-Sim/GitHub/Code/'
save_sim = 'C:/Users/jrcoyle/Documents/Research/CT-Sim/testing'

parms = list(
	dimX = 10,
	dimY = 10,
	vgm_dcorr = 1,
	habA_prop = 0.5,
	S_A = 10,
	S_B = 10,
	S_AB = 0,
	dist_b = list(type='lognormal', maxN=5, P_maxN=0.001),
	m_rates = c(.1, .1, .1),
	r_rates = c(.9, .5, .9),
	dist_d = list(mu=1.5, var=0),
	dist_v = list(mu=c(0,1), var=c(0,0),
	dist_gsad = 'b_rates',
	K = 20,
	prop_full = 1,
	init_distribute = 'same',
	cells_distribute = data.frame(x=5, y=5, n=20),
	nsteps = 20,
	d_kernel = list(type='gaussian'),
	imm_rate = 0.05,
	save_steps = seq(1, 20, 1)
)

sim_results = run_sim_N(nruns, parms, nparallel, simID, sim_dir=sim_dir)


## Examine species richness trajectories through time
use_locs = as.matrix(expand.grid(x=1:10, y=1:10))
use_locs = aggregate_cells(X=c(10,10), dX=2, dY=2, form='partition')
abun_profs = calc_abun_profile(use_locs, t_window=list(start=1, stop=20), sim_results$results[[1]], 20)
occupancy = calc_occupancy(abuns=abun_profs, do_freq=F)
tot_rich = calc_rich(abuns=abun_profs)
ct_rich = calc_rich_CT(abun_profs, occupancy, breaks=c(0.25,.5,.75), agg_times=list(1:5, 2:6, 3:7, 4:8, 5:9, 6:10, 7:11))

sample_sim(abun_profs, probs=0.01, return='presence')





breaks = c(0.33, 0.66)
b_rates = sim_results$species[[1]][,,'b']
this_land = sim_results$lands[[1]]
habitats = sapply(use_locs, function(x) average_habitat(x, this_land))

cross_classify(occupancy, c(.33, .66), b_rates, habitats, do_each=F)
cross_classify(occupancy, .5, b_rates, habitats, do_each=F)

occupancy

windows()
image(matrix(ct_rich[7,1,], nrow=10))


# TESTING
myland = make_landscape(10,10)
mysp = make_species(S_A=10, S_B=15, S_AB=3, dist_b = list(maxN=5, P_maxN=0.01, type='poisson'), m=c(0.1, 0.5), r =c(.9,.7), dist_d=list(mu=3, var=0.5))
mycomm = populate_landscape(myland, mysp, K=20, p=.5, distribution='designated', which_cells = data.frame(x=1,y=1,n=15))
mygsad = make_sad(dim(mysp)[1], distribution=list(type='same'))

mycomm = populate_landscape(myland, mysp, K=100, p=.5, distribution='designated', which_cells=data.frame(x=1,y=1,n=80))

myresults = run_sim(20, mycomm, myland, mysp, mygsad, imm_rate=.02, save_steps=seq(0,20,2))
myresults = run_timestep(mycomm, myland, mysp, mygsad, imm_rate=0.02)

which_cells = data.frame(x=1,y=1,n=80)

# TESTING

parm_list = list(
	d_kernel=list(type='gaussian'),
	imm_rate = 0.2
)
test_run = run_sim(10, mycomm, myland, mysp, mygsad, parm_list, save_steps=seq(2,10,2))
test_run = run_sim(2, mycomm, myland, mysp, mygsad)


# TESTING
mylocs = expand.grid(x=seq(2,30,3), y=seq(3,30,3))
abun_profiles = calc_abun_profile(mylocs, list(start=0, stop=10), test_run, length(mygsad))
calc_occupancy(mylocs, list(start=0, stop=10), test_run, length(mygsad), do_freq=T)
calc_occupancy(abuns = abun_profiles, which_species=10, agg_times=list(1:5))
calc_rich(mylocs, list(start=0, stop=10), test_run, length(mygsad), which_species=1:10, agg_times=2)
calc_rich(mylocs, list(start=0, stop=10), test_run, length(mygsad))


for(i in 1:nrow(locs)){
	plot_abun(abun_profiles[,,i])
	Sys.sleep(2)
}

abun_profiles

abun_profiles = calc_abun_profile(locs = as.matrix(data.frame(x=5, y=5)), t_window=list(start=1, stop=20), sim = foo, N_S=dim(this_species)[1])



*dimX
*dimY
vgm_mod
vgm_dcorr
habA_prop
*S_A
*S_B
S_AB
dist_b
*m_rates
*r_rates
dist_d
dist_gsad
K
prop_full
init_distribute
cells_distribute
*nsteps
d_kernel
imm_rate

#############################################

## Generating documentation


doc_dir = 'C:/Users/jrcoyle/Documents/Research/CT-Sim/GitHub/Documentation'
sim_dir = 'C:/Users/jrcoyle/Documents/Research/CT-Sim/GitHub/Code'

## Simulation functions
source(file.path(sim_dir, 'simulation_functions.R'))

# Find functions
obs = objects()
funcs = obs[sapply(obs, function(x) is.function(get(x)))]


for(i in 1:length(funcs)){
	prompt(filename=file.path(doc_dir,paste0(funcs[i],'.Rd')), name=funcs[i])
}














