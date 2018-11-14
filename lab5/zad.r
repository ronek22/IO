library("party")
irisdb = iris

myPredictRow <- function(sl,sw,pl,pw) {
  if(sl < 5.8 & sw > 2.9 & pl < 2.0 & pw < 1.0){
    return("setosa")
  } else {
    if(sl > 5.0 & sw < 3.0 & pl > 3.0 & pw < 2.0){
      return("versicolor")
    } else {
      return("virginica")
    }
  }
}
 
myPredict <- function(){
  passed = 0 
  for(x in 1:150) {
    if(myPredictRow(irisdb$Sepal.Length[x], irisdb$Sepal.Width[x], irisdb$Petal.Length[x], irisdb$Petal.Width[x]) == irisdb$Species[x]){
      passed = passed + 1
    }
  }
  return((passed/150)*100)
}

print(myPredict())

# utworzenie ziarna dla generatora liczb pseudolosowych
set.seed(1234)

# generowanie 150 liczb od 1 do 2
ind <- sample(2, nrow(iris), replace=TRUE, prob=c(0.67, 0.33))
# dzielenie na zbiory treningowe i testowe
iris.training <- iris[ind==1,1:5]
iris.test <- iris[ind==2,1:5]

iris.ctree <- ctree(Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width, data=iris.training)

print(iris.ctree)
plot(iris.ctree, type="simple")
predicted <- predict(iris.ctree, iris.test[,1:4])
real <- iris.test[,5]
table(predicted,real)

