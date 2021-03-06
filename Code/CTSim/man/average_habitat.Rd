% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/average_habitat.r
\name{average_habitat}
\alias{average_habitat}
\title{Average habitat values}
\usage{
average_habitat(locs, land)
}
\arguments{
\item{locs}{(required) a 2-column matrix of cell coordinates}

\item{land}{(required) a raster defining the landscape 
(see \code{\link{make_landscape}})}
}
\value{
\code{'A'} or \code{'B'}
}
\description{
Calculate the habitat type that corresponds to the average
habitat value across a set of cells in a landscape.
}

