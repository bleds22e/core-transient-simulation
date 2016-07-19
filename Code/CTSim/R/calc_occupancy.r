#' Temporal occupancy
#'
#' Calculate species' temporal occupancy in a simulation.
#'
#' The function calculates temporal occupancy for each species:
#' the fraction of timepoints a species is present in a location
#' during a given time window. Users can either supply an 
#' array of abundance profiles (as returned by 
#' \code{\link{calc_abun_profile}}) or a set of spatial units
#' (\code{locs}), a time window (\code{t_window}), simulation
#' results (\code{sim}) and the number of species (\code{N_S}), 
#' from which abundance profiles can be calculated. These parameters
#' are explained in more detail in the documentation of 
#' \code{\link{calc_abun_profile}}. For each spatial unit in
#' the abundance profiles, the function calculates the number of
#' timepoints in which each species was present and if 
#' \code{do_freq = FALSE}, divides by the total number of timepoints. 
#' If \code{do_freq = TRUE} the actual number of timepoints is returned. 
#' Timepoints may be aggregated prior to this calculation using 
#' \code{agg_times}. This can be useful for evaluating the effects 
#' of sampling at different temporal scales on observed occupancy.
#' This aggregation is relative to the timepoints
#' stored in the abundance profiles array and not to the actual 
#' timesteps in the simulation. For example, specifying 
#' \code{agg_times=10} on abundance profiles containing
#' every other timestep will aggregate abundances from \code{T=1:20,
#' T=21:40,...}.
#' 
#' @inheritParams calc_abun_profile
#' @inheritParams calc_rich 
#' @param do_freq a logical indicating whether to return actual frequencies 
#' 	rather than occupancy (which is scaled by number of timepoints). 
#' 	Defaults to FALSE.
#' @return a matrix with dimensions \code{[spatial units, species]}
#'
#' @export

calc_occupancy = function(locs=NULL, t_window=NULL, sim=NULL, N_S=NULL, abuns=NULL, agg_times=NULL, which_species=NULL, do_freq=F){
	
	# Catch error where not enough information is specified
	if(is.null(abuns)&(is.null(locs)|is.null(t_window)|is.null(sim)|is.null(N_S))) stop('Must specify abuns or locs/t_window/sim/N_S.')	

	# Calculate species abundance profiles if not specified
	if(is.null(abuns)){
		abun_profiles = calc_abun_profile(locs, t_window, sim, N_S)
	} else {
		abun_profiles = abuns
	}

	# Number of timepoints measured
	N_t = dim(abun_profiles)[1]	

	# Determine which species to examine
	if(is.null(which_species)) which_species = colnames(abun_profiles)[colnames(abun_profiles)!='0']

	# Aggregate timepoints, if specified
	if(!is.null(agg_times)){
		
		# Determine which times to aggregate
		if(is.numeric(agg_times)){
			if(length(agg_times)>1) stop('To specify non-uniform aggregation use list format.')
			int = agg_times
			agg_times = lapply(seq(1,N_t,int), function(x) x:(x+int-1))
		}

		# Calculate summed abundances across aggregation times
		# Note that new array will have dimensions  [species, locations, times]
		agg_abuns = sapply(agg_times, function(rows){
			rows = rows[rows %in% 1:N_t]
			if(length(rows)>1) new_abun = apply(abun_profiles[rows,,], 2:3, sum)
			if(length(rows)==1) new_abun = abun_profiles[rows,,]
			new_abun
		}, simplify='array')

		# Calculate number of timepoints that each specified species is present
		if(length(agg_times)==1){
			freqs = t(ifelse(agg_abuns[as.character(which_species),,]>0, 1, 0))
		} else {
			if(length(which_species)>1){
				freqs = apply(agg_abuns[as.character(which_species),,] > 0, 1:2, sum)
			} else {
				freqs = t(apply(agg_abuns[as.character(which_species),,] > 0, 1, sum))
			}
		}

		# Calculate occupancy
		if(!do_freq) freqs = freqs/length(agg_times)

	} else {

		# Calculate number of timepoints that each specified species is present
		if(length(which_species)>1){
			freqs = apply(abun_profiles[,as.character(which_species),] > 0, 2:3, sum)
		} else {
			freqs = t(apply(abun_profiles[,as.character(which_species),] > 0, 2, sum))
		}
	
		# Calculate occupancy
		if(!do_freq) freqs = freqs/N_t
	}

	# Return results as species x site matrix
	t(freqs)
}
