library(neuralnet)

normalize <- function(x) {
    return ((x - min(x)) / (max(x) - min(x)))
}

# A
iris.norm <- as.data.frame(lapply(iris[1:4], normalize))
iris.norm$Species = iris$Species
iris.norm$Setosa = iris.norm$Species == "setosa"
iris.norm$Virginica = iris.norm$Species == "virginica"
iris.norm$Versicolor = iris.norm$Species == "versicolor"
iris.norm$Species <- NULL
#B
set.seed(1234)
ind <- sample(2, nrow(iris.norm), replace=TRUE, prob=c(0.67, 0.33))
trainSet <-iris.norm[ind==1, 1:7]
testSet <-iris.norm[ind==2, 1:7]


neuralIris <- neuralnet(Setosa + Versicolor + Virginica ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width, trainSet, hidden=4)
