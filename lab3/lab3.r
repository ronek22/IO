library(genalg)

duzyProblemPlecakowy <- data.frame(wartosc = sample(10:100,30), waga = sample(10:100,30))
duzyLimit <- 600

fitnessFunc2 <- function(chr) {
  calkowita_wartosc_chr <- chr %*% duzyProblemPlecakowy$wartosc
  calkowita_waga_chr <- chr %*% duzyProblemPlecakowy$waga
  if (calkowita_waga_chr > duzyLimit)
    return(0) else return(-calkowita_wartosc_chr)
}

duzyPlecakGenAlg <- rbga.bin(size=30, popSize=200, iters=50,
                             mutationChance = 0.03, elitism = T, evalFunc=fitnessFunc2)

charData = data.frame(srednia = -duzyPlecakGenAlg$mean, maksymalne = -duzyPlecakGenAlg$best)

wykres = plot(charData$maksymalne, type='l', col='red', 
              main='Dzialanie Alg. Genetycznego', xlab='pokolenie',
              ylab='fitness(ocena)')
lines(charData$srednia, type='l', col='blue')
legend("bottomright", legend=c("Średnia", "Maksymalne"), col=c("blue", "red"), lty=1:1)