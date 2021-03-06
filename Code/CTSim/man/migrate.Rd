% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/migrate.r
\name{migrate}
\alias{migrate}
\title{Immigration}
\usage{
migrate(m, gsad)
}
\arguments{
\item{m}{(required) probability that an individual will arrive from outside
the landscape.}

\item{gsad}{(required) global relative abundance of each species. Determines
probability that migrant will belong to a given species.}
}
\value{
integer representing the species that migrates. 0 = no migrant.
}
\description{
Determine whether a species migrates into the metacommunity from outside 
the landscape.
}
\details{
Species identity is determined probabilistically according to a
global species abundance distribution (\code{gsad}).
}

