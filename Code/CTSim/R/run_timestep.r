#' Run simulation timestep
#'
#' Runs the simulation on a metacommunity for one timestep.
#'
#' Given a metacommunity (\code{metacomm}, see 
#' \code{\link{populate_landscape}}), landscape (\code{land}, 
#' see \code{\link{make_landscape}}), species pool (\code{species}, see
#' \code{\link{make_species}}), and global species abundance distribution
#' (\code{gsad}), this function calls the main process functions 
#' (\code{\link{die}, \link{reproduce}, \link{disperse}, \link{establish}})
#' to progress a metacommunity through one simulation timestep. The order
#' of operations is as follows: 
#'	\enumerate{
#'		\item \strong{Death} : Established individuals in each community experience
#'			probabilistic mortality according to species- and habitat-specific
#'			mortality rates provided in \code{species}. See \code{\link{die}}.
#'		\item \strong{Birth} : Established individuals in each community produce 
#'			propagules according to species- and habitat-specific birth rates
#'			provided in \code{species}. See \code{\link{reproduce}}.
#'		\item \strong{Dispersal} : New propagules from each community disperse 
#'			across the landscape (\code{land}) according to species-specific
#'			dispersal rates provided in \code{species}. The parameter 
#'			\code{d_kernel} specifies the dispersal kernel for new propagules.
#'			See \code{\link{disperse}}.
#'		\item \strong{Movement} : Established individuals in each community move
#'			from their current cell with species- and habitat-specific
#'			movement rates provided in \code{species}. The parameter 
#'			\code{v_kernel} specifies the dispersal kernel for previously
#'			established individuals. See \code{\link{disperse}}.
#'		\item \strong{Establishment} : Empty spaces in each community are colonized
#'			by either a migrant from outside the community with probability
#'			\code{imm_rate} or by an individual selected at random from the 
#'			pool of new propagules and moving individuals that 
#'			arrived in the cell. External migrants are chosen probabilistically
#'			from the relative abundances given in \code{gsad}. 
#'			See \code{\link{establish}}.
#'	}
#' 
#' @param metacomm (required) matrix of lists defining metacommunity  
#' 	(as generated by \code{\link{populate_landscape}} or returned by
#' 	this function).
#' @param land (required) matrix or raster of habitat types defining
#' 	the landscape (as generated by \code{\link{make_landscape}})
#' @param species (required) array of species vital rates (as generated by
#' 	\code{\link{make_species}})
#' @param gsad (required) vector defining the global relative abundance of 
#' 	each species. Must be in the same order as \code{species}. 
#' 	Defaults to same abundance for all species.
#' @param d_kernel list defining the dispersal kernel of new propagules (see 
#' 	\code{\link{get_dispersal_vec}} for options). Passed to the \code{form} 
#' 	parameter in \code{\link{disperse}}. Defaults to Gaussian.
#' @param v_kernel list defining the dispersal kernel of previously established
#' 	individuals (see \code{\link{get_dispersal_vec}} for options). Passed to 
#' 	the \code{form} parameter in \code{\link{disperse}}. Defaults to Gaussian.
#' @param imm_rate immigration rate. Passed to the parameter \code{m} in
#' 	\code{\link{establish}}. Defaults to 0.
#' @return a matrix of lists defining the metacommunity with the same 
#' 	dimensions as \code{metacomm}.
#'
#' @seealso \code{\link{run_sim}} for running multiple timesteps of 
#' 	the simulation.
#' @export

run_timestep = function(metacomm, land, species, gsad, d_kernel=NULL, v_kernel=NULL, imm_rate=NA){

	# Define dimensions of landscape
	X = nrow(land)
	Y = ncol(land)

	# Catch error where metacomm and land are different dimensions
	if(nrow(metacomm)!=X | ncol(metacomm)!=Y) stop(paste0('Dimensions of metacommunity (',paste(dim(metacomm),collapse='x'),') must match dimensions of landscape (',X,'x',Y,').'))

	# Define individual dispersal parameters if unspecified
	if(is.null(d_kernel)) d_kernel = list(type='gaussian')
	if(is.null(v_kernel)) v_kernel = list(type='gaussian')
	if(is.na(imm_rate)) imm_rate = 0

	# Define array to hold new propagule pools
	propagule_pools = matrix(list(), nrow=X, ncol=Y)

	# For each cell, new individuals are born and disperse and existing individuals move around
	for(i in 1:X){
	for(j in 1:Y){

		# Define this community and habitat
		this_comm = metacomm[i,j][[1]]
		this_habitat = get_habitat(land[i,j])

		# Stochasitic mortality
		new_comm = die(this_comm, species[, this_habitat, 'm'])

		# New individuals born
		this_pool = reproduce(new_comm, species[,this_habitat,'b'])
	
		# Propagules disperse to new pools
		prop_locs = disperse(i, j, this_pool, c(X,Y), species[,this_habitat,'d'], form=d_kernel)
		if(length(prop_locs)>0){
			for(p in 1:nrow(prop_locs)){
				# Propagules that disperse off of the landscape are removed
				if(prop_locs[p,1]>0 & prop_locs[p,2]>0 & prop_locs[p,1]<=X & prop_locs[p,2]<=Y ) propagule_pools[prop_locs[p,1], prop_locs[p,2]] = list(unlist(c(propagule_pools[prop_locs[p,1], prop_locs[p,2]], this_pool[p])))
			}
		}

		# Previously established individuals have the opportunity to move 
		move_locs = disperse(i, j, new_comm, c(X,Y), species[,this_habitat,'v'], form=v_kernel)
		for(p in 1:length(new_comm)){
			
			# If the individual exists (i.e. this is not an empty place)
			if(new_comm[p]>0){	

			# If the individual moves to a different cell
			if(move_locs[p,1]!=i | move_locs[p,2]!=j){		

			# If if individual doesn't move off the landscape
			if(move_locs[p,1]>0 & move_locs[p,2]>0 & move_locs[p,1]<=X & move_locs[p,2]<=Y ){
				
				# Add individual to pool of propagules in the new cell
				propagule_pools[move_locs[p,1],move_locs[p,2]] = list(unlist(c(propagule_pools[move_locs[p,1],move_locs[p,2]], new_comm[p])))

				# Remove the individual from the current cell
				new_comm[p] = 0
		
			}}} # closes all three if clauses
		}

		# Save existing metacommunity
		metacomm[i,j] = list(as.numeric(new_comm))

	}}
	
	# Recruits establish from propagule pools (combination of new births and previously established individuals that moved)
	for(i in 1:X){
	for(j in 1:Y){

		# Define this community, habitat and pool of propagules
		this_comm = metacomm[i,j][[1]]
		this_habitat = get_habitat(land[i,j])
		this_pool = propagule_pools[i,j][[1]]
	
		# Determine which propagules estabish
		new_comm = establish(this_comm, this_pool, species[, this_habitat, 'r'], imm_rate, gsad)

		# Save results
		metacomm[i,j] = list(as.numeric(new_comm))
	}}

	# Return new metacommunity
	metacomm
}
