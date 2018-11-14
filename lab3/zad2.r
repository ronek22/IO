library(genalg)

generatePlecakAlg <- function(backpack_size){
  duzyProblemPlecakowy <- data.frame(wartosc = sample(10:300,backpack_size), waga = sample(10:300,backpack_size))
  duzyLimit <- 600
  
  fitnessFunc2 <- function(chr) {
    calkowita_wartosc_chr <- chr %*% duzyProblemPlecakowy$wartosc
    calkowita_waga_chr <- chr %*% duzyProblemPlecakowy$waga
    if (calkowita_waga_chr > duzyLimit)
      return(0) else return(-calkowita_wartosc_chr)
  }
  
  rbga.bin(size=backpack_size, popSize=200, iters=100,
           mutationChance = 0.03, elitism = T, evalFunc=fitnessFunc2)
}

measure_time <- function(size) {
  start_time <- Sys.time()
  generatePlecakAlg(size)
  end_time <- Sys.time()
  list(size, end_time - start_time)
}

czasy <- setNames(data.frame(matrix(ncol = 2, nrow = 0)), c("dlugosc", "czas"))


czasy[nrow(czasy) + 1,] = measure_time(30)
czasy[nrow(czasy) + 1,] = measure_time(60)
czasy[nrow(czasy) + 1,] = measure_time(120)
czasy[nrow(czasy) + 1,] = measure_time(200)

wykres = plot(czasy, col='red', 
              main='Czas Alg. Genetycznego', xlab='Długość chromosomu',
              ylab='Czas trawnia obliczen')



