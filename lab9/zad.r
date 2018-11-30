siatka <- data.frame(
  wiek <- c(23, 25, 28, 22, 46, 50, 48),
  waga <- c(75, 67, 120, 65, 70, 68, 97),
  wzrost <- c(176, 180, 175, 165, 187, 180, 178),
  neuron <- c(0)
)
names(siatka) <- c("wiek", "waga", "wzrost", "neuron")


forwardPass <- function(wiek, waga, wzrost) {
  hidden1 <- 
    fct.act(wiek*-0.46122+waga*0.97314+wzrost*-0.39203+0.80109)
  hidden2 <-
    fct.act(wiek*0.78548+waga*2.10584+wzrost*-0.57847+0.43529)
  output <- (hidden1*-0.81546+hidden2*1.03775-0.2368)
  return(output)
}

fct.act <- function(x) {
  return(1/(1+exp(-x)))
}

for (i in 1:nrow(siatka)) {
   siatka$neuron[i] <- forwardPass(siatka$wiek[i],siatka$waga[i], siatka$wzrost[i])
}

print(forwardPass(23,75,176))
print(siatka)