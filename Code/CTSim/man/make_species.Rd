% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/make_species.r
\name{make_species}
\alias{make_species}
\title{Creation of species pool}
\usage{
make_species(S_A = NA, S_B = NA, S_AB = NA, dist_b = NULL, m, r,
  dist_d = NULL, dist_v = NULL)
}
\arguments{
\item{S_A}{(required) number of specialist species for habitat type A}

\item{S_B}{(required) number of specialist species for habitat type B}

\item{S_AB}{number of generalist species (defaults to 0)}

\item{dist_b}{named list describing the distribution from 
which birth rates should be drawn (see \code{distribution} 
parameter in \code{\link{make_sad}}). Defaults to uniform on [1,10].}

\item{m}{(required) vector of length 2 or 3 specifying death rates 
[preferred habitat, non-preferred habitat, generalist rate]}

\item{r}{(required) vector of length 2 or 3 specifying recruitment rates 
[preferred habitat, non-referred habitat, generalist rate]}

\item{dist_d}{named list of parameters describing distribution from which 
    expected propagule dispersal distances should be drawn. 
Defaults to 1 for all species.
    Contains:
\describe{
        \item{\code{u}}{mean dispersal distance}
        \item{\code{var}}{variance of the distribution from which  
            distances are drawn. Defaults to 0 for the same 
        dispersal kernal for all species.}
    \item{\code{type}}{character string defining form of the dispersal 
        kernel. See \code{\link{get_dispersal_vec}} for options. 
        Defaults to gaussian.}
}}

\item{dist_v}{named list of parameters describing distribution from which 
    expected movement distances should be drawn. Defaults to 0 for all species  
    in all habitats. Contains:
    \describe{
    \item{\code{mu}}{vector of length 2 or 3 specifying mean movement 
            distance [preferred habitat, non-preferred habitat, generalist rate]}
    \item{\code{var}}{vector of length 2 or 3 specifying variance of the 
        gamma distributions from which movement distances are drawn 
            [preferred habitat, non-preferred habitat, generalist rate]. 
        Defaults to 0 for the same movement kernal for 
            all species.}
    \item{\code{type}}{character string defining form of the movement 
        kernel. See \code{\link{get_dispersal_vec}} for options. 
        Defaults to gaussian.} 
}}
}
\value{
an array with dimensions \code{[S_A+S_B+S_AB, 2, 5]}
}
\description{
Creates an array to hold species vital rates.
}
\details{
A species pool is defined by a 3-dimensional array
in which the first dimension holds species, the second
defines which habitat the rate applies to ('A' or 'B'), and the third 
hols the type of rate: 
\enumerate{
	\item \code{'b'} birth = number of offpsring produced by established
	 individual per timestep
\item \code{'m'} mortality = probability that established individual
	 dies during a time step
\item \code{'r'} recruitment = probability than a propagule arriving
	 at an open space will become an established individual
\item \code{'d'} dispersal = expected distance that a propagule will 
	disperse from its origination point 
	\item \code{'v'} movement = expected distance that an established 
		individual will move from its cell
}
Birth rates are positive in a species' preferred habitat and 0 elsewhere.
Generalists prefer both habitat types equally. Dispersal rates control how
newly produced propagules move away from their cell of origin. Movement rates
control how established individuals move from their current cell. Movement,
mortality, and recruitment rates can be set to differe systematically between
preferred and non-preferred habitats.
}

