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
# B
set.seed(1234)
ind <- sample(2, nrow(iris.norm), replace=TRUE, prob=c(0.67, 0.33))
trainSet <-iris.norm[ind==1, 1:8]
testSet <-iris.norm[ind==2, 1:8]

# C
neuralIris <- neuralnet(Setosa + Versicolor + Virginica ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width, trainSet, hidden=4)
plot(neuralIris)

# D
pr <- compute(neuralIris, testSet[,1:4])
result <- as.data.frame(pr$net.result)
colnames(result) <- c("Setosa", "Versicolor", "Virginica")

predicted <- colnames(result)[max.col(result,ties.method="first")]
real <- testSet$Species

conf.matrix <- table(predicted, real)
