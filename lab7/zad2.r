iris.log <- log(iris[,1:4])
iris.stand <- scale(iris.log, center=TRUE)
iris.pca <- prcomp(iris.stand)
iris.final <- predict(iris.pca)[,1:2]
iris.test <- as.data.frame(iris.final)
iris.test$Species <- iris$Species

real_plot <- function() {
  plot(iris.final)
  points(iris.test$PC1[1:50], iris.test$PC2[1:50], col=1)
  points(iris.test$PC1[51:100], iris.test$PC2[51:100], col=2)
  points(iris.test$PC1[101:150], iris.test$PC2[101:150], col=3)
}

predicted_plot <- function() {
  k <- kmeans(iris.final, 3)
  plot(iris.final, col=k$cluster)
  points(k$centers, col=1:3, pch=8, cex=2)
}

predicted_plot()
#real_plot()



