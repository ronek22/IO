normalize <- function(input) {
 # ((my_data$wyplata-min_wyplata)/(max_wyplata-min_wyplata))
  minimum = min(input)
  maximum = max(input)
  normalize_vector <- c()
  
  for(i in input) {
    normalize_vector <- c(normalize_vector, (i-minimum)/(maximum-minimum))
  }
  return(normalize_vector)
}

standarize <- function(input) {
  srednia = mean(input)
  odchylenie = sd(input)
  standarized_vector <- c()
  for(i in input){
    standarized_vector <- c(standarized_vector, (i-srednia)/odchylenie)
  }
  return(standarized_vector)
}