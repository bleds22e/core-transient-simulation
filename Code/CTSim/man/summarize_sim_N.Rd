% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summarize_sim_N.r
\name{summarize_sim_N}
\alias{default_sum_func}
\alias{summarize_sim_N}
\title{Summarize multiple simulations}
\usage{
summarize_sim_N(sim, breaks, locs, t_window, agg_times = NULL,
  P_obs = list(1), sum_parms = NULL, sum_func = NULL, sum_turn = TRUE)

default_sum_func(x)
}
\arguments{
\item{sim}{(required) either the name of a directory containing
multiple simulation results (as saved by \code{\link{run_sim_N}}) 
or an array of simulation results returned by the same function.}

\item{breaks}{(required) a vector of numbers on \code{[0,1]} (in order) 
specifying boundaries of occupancy categories}

\item{locs}{(required) either a two-column matrix of cell locations where 
species' abundances should be summed or a list of matrices designating
multiple spatial units where abundance should be summed (see 
\code{\link{calc_abun_profile}})}

\item{t_window}{(required) either a list containing \code{start}
and \code{stop} specifying that all collected timepoints in that interval
should be considered or an explicit vector of timepoints}

\item{agg_times}{either a single number specifing the number of timepoints 
that should be aggregated before calculating occupancy or a list of
vectors defining exactly which timepoints should be aggregated 
(see \code{\link{summarize_sim}}). Defaults to no aggregation.}

\item{P_obs}{vector of detection probabilities (see \code{\link{sample_sim}}
and \code{\link{summarize_sim}}). Defaults to 1.}

\item{sum_parms}{list of parameters controlling how the simulation is 
    summarized across spatial and temporal units. May contain:
    \describe{
        \item{agg_times}{specifies how time points should be aggregated 
        before calculations. See \code{\link{calc_rich_CT}} for details.}
    \item{time_sum}{character vector indicating which timepoint
        should be used in summary statistics (see 
        \code{\link{summarize_sim}})}
    \item{quants}{vector of quantiles for summarizing across spatial units
        (see \code{\link{summarize_sim}})}
}}

\item{sum_func}{function used to summarize quantities across simulation
runs. Consider using \code{default_sum_func}. Default is no summary with 
quantities returned for each run individually.}

\item{sum_turn}{logical indicating whether turnover rates should be
summarized. Defaults to \code{TRUE}.}

\item{x}{vector of numbers to summarize
quantities across simulation runs}
}
\value{
a list of arrays defined in as follows
	\describe{
		\item{bio}{richness and abundance of biologically defined species,
			has dimensions: \code{[run or cross-run summary statistic,
		richness or abundance, spatial summary statistic, core or 
			transient, detection probability]}}
		\item{occ}{richness and abundance in temporal occupancy categories,
			has dimensions: \code{[run or cross-run summary statistic, 
			richness or abundance, spatial summary statistic, occupancy 
			category, detection probability]}}
		\item{xclass}{core-transient cross-classification,
			has dimensions: \code{[run or cross-run summary statistic, spatial 
			 summary statistic, cross-classification category, 
			detection probability]}}
		\item{abun}{species' relative abundances, has dimensions:
			\code{[run or cross-run summary statistic, species, 
			detection probability]}}
		\item{land}{summary of landscape properties, has dimensions:
			\code{[run or cross-run summary statistic, landscape statistic]}}
	}
	If \code{sum_parms$time_sum = 'none'} then each of these arrays will
	have an additional dimension corresponding to timepoints.
}
\description{
Summarizes multiple simulations run on the same set of parameters.
}
\details{
The function summarizes each simulation run as described in 
\code{\link{summarize_sim}}. In addition, it also summarizes landscape
properties across the spatial units specified in \code{locs} using 
\code{\link{summarize_land}} for the landscapes used in each simulation run.
If \code{sum_func} is provided, this function is used to 
summarize quantities across runs. The package includes a useful default 
summary function (\code{default_sum_func}) which can be passed to 
\code{sum_func}. It returns the mean, variance and qunatiles at 
\code{2.5\%}, \code{50\%} and \code{97.5\%}.

Simulation runs to summarize can be specified in two ways to the 
parameter \code{sim}: by passing the list of simulation results returned 
by \code{\link{run_sim_N}} or by passing the name of the directory where 
multiple simulation result files are saved. Simulation run files are
identified by ending in 'run<\code{i}>.RData', where \code{i} is a 
number. This is the naming format that is automatically generated by 
\code{\link{run_sim_N}}.
}
\section{Functions}{
\itemize{
\item \code{summarize_sim_N}: Summarize multiple simulation runs

\item \code{default_sum_func}: Basic function to calculate statistics summarizing
}}

