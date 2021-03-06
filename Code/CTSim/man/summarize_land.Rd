% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summarize_land.r
\name{summarize_land}
\alias{summarize_land}
\title{Summarize landscape habitats}
\usage{
summarize_land(sim, locs)
}
\arguments{
\item{sim}{(required) either a filename for a simulation run (as saved by
\code{\link{run_sim_N}} or a raster landscape (as returned by 
\code{\link{make_landscape}}.}

\item{locs}{(required) either a two-column matrix of cell locations defining 
a single spatial unit or a list of matrices designating
multiple spatial units}
}
\value{
a named vector with the dominant habitat proportion, habitat 
	variance, and habitat heterogeneity (see details)
}
\description{
Summarizes habitat characteristics at a set of locations across a landscape.
}
\details{
The function tabulates habitat types found in each spatial unit specified in
\code{locs} and each spatial unit is assigned to its dominant habitat type.
Then, the function calculates the proportion of spatial units in the 
dominant habitat type and the variance in habitat across spatial units
(assuming a Bernoulli distribution: \code{var = p(1-p)}). Finally, the function
calculates a measure of habitat heterogeneity from 
\href{http://dx.doi.org/10.1046/j.1440-1703.2000.00326.x}{Shiyomi 
and Yoshimura (2000), Ecological Research 15: 13-20},
which is a variance:mean ratio corrected for finite count data. 
For each spatial unit it counts the number of cells that are the dominant 
habitat typeand then compares the variance and mean of these frequencies. 
A value of zero indicates random distribution at that scale.
}

