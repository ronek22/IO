library(genalg)

#rows = list(c(1,1), 2, 1)
#cols = list(c(1,1), 1, 2)

rows = list(c(1,1), c(2,2), 3, 2, 2)
cols = list(c(2,2), 4, 1, 2, 2)

m = length(rows)
n = length(cols)

basic_checker <- function(row, rules){
  # za malo zamalowynych pol, 
  # koncze dzialanie
  if(sum(rules) != sum(row==1)){
    return(0)
  }
  
  nrule = 1
  seq = 0
  in_seq = FALSE
  for(i in 1:length(row)){
    if(row[i] == 0 & in_seq == FALSE){

    } 
    else if(row[i] == 1 & in_seq == FALSE) {
      seq = seq + 1
      in_seq = TRUE
    }
    else if(row[i] == 1 & in_seq == TRUE){
      seq = seq + 1
      if(seq > rules[nrule]) return(0)
    }
    else if(row[i] == 0 & in_seq == TRUE){
      if(seq == rules[nrule]) {
        in_seq = FALSE
        seq = 0
        if(nrule + 1 <= length(rules)){
          nrule = nrule + 1
        }
      } else {
        return(0)
      }
    }
  }
  return(-1)
}
better_checker <- function(row, rules){
  pts = 0
  end = FALSE   # czy kryteria sa juz spelnione
  nrule = 1
  seq = 0   #licznik sekwencji
  in_seq = FALSE   # czy jestesmy w sekwnecji 1
  after_seq = FALSE # za duzo 1, ale ciagle w sekwencji
  
  for(i in 1:length(row)){
    if(row[i] == 1 & end==TRUE){
      pts = pts + 1
    }
    if(row[i] == 0 & in_seq == FALSE | row[i] == 1 & after_seq == TRUE){
      
    } 
    else if(row[i] == 1 & in_seq == FALSE) {
      seq = seq + 1
      in_seq = TRUE
    }
    else if(row[i] == 1 & in_seq == TRUE){
      seq = seq + 1
      if(seq > rules[nrule]){
        pts = pts + 1 # nadmiar jedynek + 1
        in_seq = FALSE
        after_seq = TRUE
      } else if(seq == rules[nrule]){
        pts = pts - 1 # dojscie do odpowiedniej dlugosci sekwencji - 1
        if(i == length(row)){
          pts = pts - 1 # koniec wiersza liczy sie jak dobra przerwa
        }
      }
    }
    else if(row[i] == 0 & in_seq == TRUE | row[i] == 0 & after_seq == TRUE){
      if(seq == rules[nrule]) {
        pts = pts - 1
      } else if(seq < rules[nrule]){
        pts = pts + 1
      }
      if(nrule + 1 <= length(rules)){
        nrule = nrule + 1
      } else {
        end = TRUE
      }
      in_seq = FALSE
      seq = 0
    }
  }
  return(pts)
}

# chromosom ma dlugosc rowna ilosci pol
# 1 oznacza, że pole zostało wypełnione
# 0, że zostało puste
fitnessFunc <- function(chr) {
  suma = 0
  # tworzenie macierzy z chromosomu
  matrx = matrix(chr, nrow = m, ncol = n, byrow=TRUE)
  
  for(i in 1:m){
    suma = suma + better_checker(matrx[i,], rows[[i]])
  }
  for(i in 1:n){
   suma = suma + better_checker(matrx[,i], cols[[i]])
  }
  
  return(suma)
}

nonoGenAlg <- rbga.bin(size = n*m, popSize = 300, iters = 100,
                        mutationChance = 0.05, elitism = T, evalFunc = fitnessFunc)




bestSolution <- nonoGenAlg$population[which.min(nonoGenAlg$evaluations),]
print("Best  result: ")
print(min(nonoGenAlg$best))
print("Best solution at: ")
print(which.min(nonoGenAlg$best))
best <- matrix(bestSolution, nrow=m, ncol=n, byrow=TRUE)
print(best)
