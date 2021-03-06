% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summarize_sim_P.r
\name{summarize_sim_P}
\alias{summarize_sim_P}
\title{Summarize with multiple parameter sets}
\usage{
summarize_sim_P(run_dir = "./", parm_dir = "./",
  results_dir = "./Summaries/", cross_time = F)
}
\arguments{
\item{run_dir}{directory where simulation runs are located.
Defaults to the current directory.}

\item{parm_dir}{directory where parameter files are located.
Defaults to the current directory.}

\item{results_dir}{directory where results should be saved.
Defaults to 'Summaries' in the current directory.}

\item{cross_time}{logical indicating whether to use \code{t_window}
to summarize the simulation in windows of time}
}
\value{
nothing
}
\description{
Summarize simulation runs with multiple sets of parameters
}
\details{
This function summarizes multiple simulation runs with multiple
sets of parameters, which are saved in the directory
given in \code{parm_dir}. Parameter filenames must start with 's_'.
Each parameter file should have a unique \code{sumID} defined within it
as well define objects that can be passed as parameters to 
\code{\link{summarize_sim_N}}. Parameters
requiring a value are \code{breaks}, \code{locs} and \code{t_window}.
The function will either summarize simulation results for a set time period
defined in \code{t_window} (default) or for multiple consecutive time windows
 (use \code{cross_time=TRUE}), in which case \code{t_window} 
defines the time interval and must be a list with named elements
\code{start} and \code{stop}. If \code{cross_time=FALSE} then 
two summary objects are saved to the .RData file: \code{sim_sum_ind}- 
includes a summary for each run, and \code{sim_sum}- summarizes quantities 
across runs using the function defined in \code{sum_func}. 
If \code{cross_time=TRUE} then only \code{sim_sum_ind} is saved and 
\code{T=<time>} is appended to the filename to denote the timestep at 
which the summary ends.
Results are saved in the directory \code{results_dir} and are not returned
by the function. Filenames follow the convention 
\code{<sumID>_summary.RData}.
}
\seealso{
\code{\link{summarize_simulation}} for command line execution
}

