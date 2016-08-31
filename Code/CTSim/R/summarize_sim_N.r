#' Summarize multiple simulations
#'
#' Summarizes multiple simulations run on the same set of parameters.
#'
#' The function summarizes each simulation run as described in 
#' \code{\link{summarize_sim}}. In addition, it also summarizes landscape
#' properties across the spatial units specified in \code{locs} using 
#' \code{\link{summarize_land}} for the landscapes used in each simulation run.
#' If \code{sum_func} is provided, this function is used to 
#' summarize quantities across runs. The package includes a useful default 
#' summary function (\code{default_sum_func}) which can be passed to 
#' \code{sum_func}. It returns the mean, variance and qunatiles at 
#' \code{2.5\%}, \code{50\%} and \code{97.5\%}. 
#' 
#' Simulation runs to summarize can be specified in two ways to the 
#' parameter \code{sim}: by passing the list of simulation results returned 
#' by \code{\link{run_sim_N}} or by passing the name of the directory where 
#' multiple simulation result files are saved. Simulation run files are
#' identified by ending in 'run<\code{i}>.RData', where \code{i} is a 
#' number. This is the naming format that is automatically generated by 
#' \code{\link{run_sim_N}}.
#'
#' @param sim (required) either the name of a directory containing
#' multiple simulation results (as saved by \code{\link{run_sim_N}}) 
#' or an array of simulation results returned by the same function. 
#' @param breaks (required) a vector of numbers on \code{[0,1]} (in order) 
#' 	specifying boundaries of occupancy categories
#' @param locs (required) either a two-column matrix of cell locations where 
#' 	species' abundances should be summed or a list of matrices designating
#' 	multiple spatial units where abundance should be summed (see 
#' 	\code{\link{calc_abun_profile}})
#' @param t_window (required) either a list containing \code{start}
#' 	and \code{stop} specifying that all collected timepoints in that interval
#' 	should be considered or an explicit vector of timepoints
#' @param agg_times either a single number specifing the number of timepoints 
#' 	that should be aggregated before calculating occupancy or a list of
#' 	vectors defining exactly which timepoints should be aggregated 
#' 	(see \code{\link{summarize_sim}}). Defaults to no aggregation.
#' @param P_obs vector of detection probabilities (see \code{\link{sample_sim}}
#' 	and \code{\link{summarize_sim}}). Defaults to 1.
#' @param sum_parms list of parameters controlling how the simulation is 
#' 	summarized across spatial and temporal units. May contain:
#' 	\describe{
#' 		\item{agg_times}{specifies how time points should be aggregated 
#'			before calculations. See \code{\link{calc_rich_CT}} for details.}
#'		\item{time_sum}{character vector indicating which timepoint
#'			should be used in summary statistics (see 
#'			\code{\link{summarize_sim}})}
#'		\item{quants}{vector of quantiles for summarizing across spatial units
#'			(see \code{\link{summarize_sim}})}
#'	}
#' @param sum_func function used to summarize quantities across simulation
#' 	runs. Consider using \code{default_sum_func}. Default is no summary with 
#' 	quantities returned for each run individually.
#' @return a list of arrays defined in as follows
#' 	\describe{
#' 		\item{bio}{richness and abundance of biologically defined species,
#' 			has dimensions: \code{[run or cross-run summary statistic,
#'			richness or abundance, spatial summary statistic, core or 
#' 			transient, detection probability]}}
#' 		\item{occ}{richness and abundance in temporal occupancy categories,
#' 			has dimensions: \code{[run or cross-run summary statistic, 
#' 			richness or abundance, spatial summary statistic, occupancy 
#' 			category, detection probability]}}
#' 		\item{xclass}{core-transient cross-classification,
#' 			has dimensions: \code{[run or cross-run summary statistic, spatial 
#' 			 summary statistic, cross-classification category, 
#' 			detection probability]}}
#' 		\item{abun}{species' relative abundances, has dimensions:
#' 			\code{[run or cross-run summary statistic, species, 
#' 			detection probability]}}
#' 		\item{land}{summary of landscape properties, has dimensions:
#' 			\code{[run or cross-run summary statistic, landscape statistic]}}
#' 	}
#' 	If \code{sum_parms$time_sum = 'none'} then each of these arrays will
#' 	have an additional dimension corresponding to timepoints.
#'
#' @import abind

#' @describeIn summarize_sim_N Summarize multiple simulation runs 
#' @export
summarize_sim_N = function(sim, breaks, locs, t_window, agg_times=NULL, P_obs=list(1), sum_parms=NULL, sum_func=NULL){

	# If sim is a file, then read in simulation run. Should have objects: results, this_land, this_species, this_gsad
	if(is.character(sim)){

		# Find all simulation runs in ths directory
		runfiles = list.files(sim, '*run[0-9]+.RData')
		
		# Read in first file
		this_run = file.path(sim, runfiles[1])
		this_sum = summarize_sim(this_run, breaks=breaks, locs=locs, t_window=t_window, agg_times=agg_times, P_obs=P_obs, sum_parms=sum_parms)

		# Create arrays to hold summaries
		bio_arr = this_sum$bio
		occ_arr = this_sum$occ
		xclass_arr = this_sum$xclass
		abun_arr = this_sum$abun
		land_arr = summarize_land(this_run, locs=locs)

		if(length(runfiles)>1){
			for(i in 2:length(runfiles)){
				f = runfiles[i]
				this_run = file.path(sim, f)
				this_sum = summarize_sim(this_run, breaks=breaks, locs=locs, t_window=t_window, agg_times=agg_times, P_obs=P_obs, sum_parms=sum_parms)
				bio_arr = abind::abind(bio_arr, this_sum$bio, along=ifelse(i==2, 0, 1))	
				occ_arr = abind::abind(occ_arr, this_sum$occ, along=ifelse(i==2, 0, 1))	
				xclass_arr = abind::abind(xclass_arr, this_sum$xclass, along=ifelse(i==2, 0, 1))
				abun_arr = abind::abind(abun_arr, this_sum$abun, along=ifelse(i==2, 0, 1))

				land_arr = abind::abind(land_arr, summarize_land(this_run, locs=locs), along=ifelse(i==2, 0, 1))	
			}
		}
	}
	
	# If sim is a list returned by run_sim_N()
	if(is.list(sim)){
		
		# Extract first run
		this_sum = summarize_sim(sim$results[[1]], species=sim$species[[1]], land=sim$lands[[1]], gsad=sim$gsads[[1]],
			breaks=breaks, locs=locs, t_window=t_window, agg_times=agg_times, P_obs=P_obs, sum_parms=sum_parms)
		
		# Create arrays to hold summaries
		bio_arr = this_sum$bio
		occ_arr = this_sum$occ
		xclass_arr = this_sum$xclass
		abun_arr = this_sum$abun
		land_arr = summarize_land(sim$lands[[1]], locs=locs)
		
		if(length(sim$results)>1){
			for(i in 2:length(sim$results)){
				this_sum = summarize_sim(sim$results[[i]], species=sim$species[[i]], land=sim$lands[[i]], gsad=sim$gsads[[i]],
					breaks=breaks, locs=locs, t_window=t_window, agg_times=agg_times, P_obs=P_obs, sum_parms=sum_parms)
				bio_arr = abind::abind(bio_arr, this_sum$bio, along=ifelse(i==2, 0, 1))	
				occ_arr = abind::abind(occ_arr, this_sum$occ, along=ifelse(i==2, 0, 1))	
				xclass_arr = abind::abind(xclass_arr, this_sum$xclass, along=ifelse(i==2, 0, 1))
				abun_arr = abind::abind(abun_arr, this_sum$abun, along=ifelse(i==2, 0, 1))

				land_arr = abind::abind(land_arr, summarize_land(sim$lands[[i]], locs=locs), along=ifelse(i==2, 0, 1))	
			}
		}
	}

	if(is.null(sum_func)){

		# Name the dimensions
		if(tryCatch(sum_parms$time_sum=='none', error=function(e) FALSE)){
			names(dimnames(bio_arr)) = c('run', 'comm_stat','cross_space','timestep','category','p_obs')
			names(dimnames(occ_arr)) = c('run', 'comm_stat','cross_space','timestep','category','p_obs')
			names(dimnames(abun_arr)) = c('run', 'sp_rank','timestep','p_obs')
		} else{
			names(dimnames(bio_arr)) = c('run', 'comm_stat','cross_space','category','p_obs')
			names(dimnames(occ_arr)) = c('run', 'comm_stat','cross_space','category','p_obs')
			names(dimnames(abun_arr)) = c('run', 'sp_rank', 'p_obs')
		}
		names(dimnames(xclass_arr)) = c('run','cross_space','ab_ct','p_obs')
		names(dimnames(land_arr)) = c('run','stat')
		
		# Return arrays where first dimension is the run
		return(list(bio=bio_arr, occ=occ_arr, xclass=xclass_arr, abun=abun_arr, land=land_arr))

	} else {
		if(!is.function(sum_func)) stop('Argument sum_func must be a function.')
		
		# Summarize across runs
		bio_sum = apply(bio_arr, 2:length(dim(bio_arr)), sum_func)
		occ_sum = apply(occ_arr, 2:length(dim(occ_arr)), sum_func)
		xclass_sum = apply(xclass_arr, 2:length(dim(xclass_arr)), sum_func)
		abun_sum = apply(abun_arr, 2:length(dim(abun_arr)), sum_func)
		land_sum = apply(land_arr, 2, sum_func)

		# Name the dimensions
		if(tryCatch(sum_parms$time_sum=='none', error=function(e) FALSE)){
			names(dimnames(bio_sum)) = c('cross_run', 'comm_stat','cross_space','timestep','category','p_obs')
			names(dimnames(occ_sum)) = c('cross_run', 'comm_stat','cross_space','timestep','category','p_obs')
			names(dimnames(abun_sum)) = c('cross_run', 'sp_rank','timestep','p_obs')
		} else{
			names(dimnames(bio_sum)) = c('cross_run', 'comm_stat','cross_space','category','p_obs')
			names(dimnames(occ_sum)) = c('cross_run', 'comm_stat','cross_space','category','p_obs')
			names(dimnames(abun_sum)) = c('cross_run', 'sp_rank', 'p_obs')
		}
		names(dimnames(xclass_sum)) = c('cross_run','cross_space','ab_ct','p_obs')
		names(dimnames(land_sum)) = c('cross_run','stat')
		
		# Return summaries across runs. If sum_func returns a vector, then the first dimension is the summaries across runs.	
		return(list(bio=bio_sum, occ=occ_sum, xclass=xclass_sum, abun=abun_sum, land=land_sum))
	}
}

#' @describeIn summarize_sim_N Basic function to calculate statistics summarizing
#' @param x vector of numbers to summarize
#' 	quantities across simulation runs
#' @export
default_sum_func = function(x){
	# Check whether all values are NA (as in the case of calculating variance from one spatial unit)
	NAs = sum(is.na(x))
	
	if(length(x)==NAs){
		c(mean=NA, var=NA, '2.5%'=NA, '50%'=NA, '97.5%'=NA, NAs=NAs)
	} else {
		c(mean=mean(x, na.rm=T), var=var(x, na.rm=T), quantile(x, c(0.025, 0.5, 0.975), 
			na.rm=T), NAs = sum(is.na(x)))
	}
}
