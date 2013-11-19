\name{spGaussLogLik}
\alias{spGaussLogLik}

\title{
Density evalaution for a spatial Gaussian Copula
}
\description{
Evaluates the density for a spatial Gaussian Copula.
}
\usage{
spGaussLogLik(corFun, neigh, log = T)
}

\arguments{
  \item{corFun}{
A valid correlogram (i.e. producing a valid correlation matrix; e.g. based on a variogram).
}
  \item{neigh}{
A \code{\linkS4class{neighbourhood}} object to be evaluated.
}
  \item{log}{
Should the log-likelihood be returned?
}
}
\details{
Evaluates the density for all neioghbourhoods in \code{neigh} and returns the (log)-likelihood.
}
\value{
The (log)-likelihood value.
}
\author{
Benedikt Graeler
}

\examples{
library(spcopula)

# load data from the Meuse demo
data(spCopDemo)

# calculate the correlation function based on Kendall's tau
calcKTauPol <- fitCorFun(bins, degree=1)

# translate Kendall's tau correlation function into Gaussian Copula parameters 
# using a linear variogram
meuseGaussCorFun <- function(h) {
  res <- pmax(iTau(normalCopula(0), calcKTauPol(0))/658*(658-h),0)
  res[h ==0] <- 1
  return(res)
}

# get the neighbours
library(sp)
data(meuse)
coordinates(meuse) <- ~x+y

meuse$rtZinc <- rank(meuse$zinc)/(length(meuse)+1)

meuseNeigh <- getNeighbours(meuse, var="rtZinc", size=5L, 
                            prediction=FALSE)

# calculate the log-likelihood
spGaussLogLik(meuseGaussCorFun, meuseNeigh)
}

\keyword{ distribution }