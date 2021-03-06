% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/find_spat_f_naive.R
\name{find_spat_f_naive}
\alias{find_spat_f_naive}
\title{find spatial Fs (fishing mortality rates), naive methods of C/B for speed}
\usage{
find_spat_f_naive(C = C, B = B)
}
\arguments{
\item{C}{is a Numeric vector detailing the catch at \eqn{wk_{t}}}

\item{B}{is a Numeric vector of the biomass at \eqn{wk_{t}}}
}
\value{
Gives a matrix the spatial fishing mortality estimate \emph{F}
}
\description{
\code{find_spat_f} uses \code{\link[base]{uniroot}} to find the
fishing mortality rate for a population given the catch, biomass and natural
mortality using the \code{\link{baranov_f}} objective function.
}
\examples{
find_spat_f_naive(C = matrix(1000,3000, nc =2), B =
matrix(12000,10000, ncol = 2))
}
