## librarys ##
library(spcopula)
library(evd)

## dataset - spatial poionts data.frame ##
data(meuse)
coordinates(meuse) = ~x+y
dataSet <- meuse

spplot(meuse,"zinc")

## margins ##
hist(dataSet[["zinc"]],freq=F,n=30,ylim=c(0,0.0035))
gevEsti <- fgev(dataSet[["zinc"]])$estimate
loc <- gevEsti[1]
scale <- gevEsti[2]
shape  <- gevEsti[3]
meanLog <- mean(log(meuse[["zinc"]]))
sdLog <- sd(log(meuse[["zinc"]]))
curve(dgev(x,loc,scale,shape),add=T,col="red")
curve(dlnorm(x,meanLog,sdLog),add=T,col="green")

ks.test(dataSet[["zinc"]],pgev,loc,scale,shape) # p: 0.07
ks.test(dataSet[["zinc"]],plnorm,meanLog,sdLog) # p: 0.03

## lag classes ##
bins <- calcBins(dataSet,var="zinc",nbins=10,cutoff=800)

# transform data to the unit interval
bins$lagData <- lapply(bins$lagData, function(x) cbind(rank(x[,1])/(nrow(x)+1),rank(x[,2])/(nrow(x)+1)))

abline(h=0,col="red")
modelCoeff <- lm(bins$lagCor[1:7]~bins$meanDists[1:7])$coefficients 
abline(modelCoeff,col="blue") # 8 lags
range <- as.numeric(-modelCoeff[1]/modelCoeff[2])

## calculate parameters for Kendall's tau function ##
# either linear
calcKTau <- function(h) pmax(h*modelCoeff[2]+modelCoeff[1],0)
curve(calcKTau,0, 1000, col="red", add=T)

# or polynomial
calcKTau <- fitCorFun(bins)
curve(calcKTau,0, 1000, col="purple",add=T)

## find best fitting copula per lag class
loglikTau <- loglikByCopulasLags(bins, calcKTau)
bestFitTau <- apply(apply(loglikTau[1:7,], 1, rank),2,function(x) which(x==5))

## set-up a spatial Copula ##
spCop <- spCopula(components=list(normalCopula(0), tCopula(0, dispstr = "un"),
                                  frankCopula(1), normalCopula(0), claytonCopula(0),
                                  claytonCopula(0), claytonCopula(0)),
                  distances=c(bins$meanDists[1:7],range),
                  spDepFun=calcKTau, unit="m")

