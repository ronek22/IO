setwd("~/Studia/Inteligencja/lab2")

# zadanie 1
plecakdb <- data.frame(
  przedmiot = c("zegar", "obraz-pejzaż",
                "obraz-portret", "radio", "laptop", "lampka nocna", 
                "srebrne sztućce", "porcelana", "figura z brązu", "skórzana
                torebka", "odkurzacz"),
  wartosc = c(100, 300, 200, 40, 500, 70, 100, 250, 300,280,300),
  waga = c(7, 7, 6, 2, 5, 6, 1, 3, 10, 3, 15)
)

plecaklimit <- 25
chromosome = c(0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1)
plecakdb[chromosome == 1, ]
cat(chromosome %*% plecakdb$wartosc)

fitnessFunc <- function(chr) {
  calkowita_wartosc_chr <- chr %*% plecakdb$wartosc
  calkowita_waga_chr <- chr %*% plecakdb$waga
  if (calkowita_waga_chr > plecaklimit)
    return(0) else return(-calkowita_wartosc_chr)
}

plecakGenAlg <- rbga.bin(size = 11, popSize = 200, iters = 100,
                         mutationChance = 0.05, elitism = T, evalFunc = fitnessFunc)

summ = summary(plecakGenAlg, echo=TRUE)
best_solution = c(0,1,1,0,1,0,1,1,0,1,0)
cat("Sumaryczna wartosc dla najlepszego:", best_solution %*% plecakdb$wartosc)