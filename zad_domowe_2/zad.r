library(party)
library(class)
library(e1071)
data = read.csv("processed.cleveland.csv", header=TRUE, sep=',')

data[data == "?"] <- NA
data <- na.omit(data)

data$ca <- as.character(data$ca) 
data$ca <- as.numeric(data$ca)
data$thal <- as.numeric(data$thal)

data$output = ifelse(data$output == 0, "No", "Yes")
data$output = as.factor(data$output)

# dzielenie na zbior treningowy i testowy
set.seed(1234)
ind <- sample(2, nrow(data), replace=TRUE, prob=c(0.8,0.2))
data.training <- data[ind==1, 1:14]
data.test <- data[ind==2, 1:14]


# Drzewa 
data.ctree <- ctree(output ~ age + sex + cp + trestbps + chol + 
                      fbs + restecg + thalach + exang + oldpeak + 
                      slope + ca + thal, data = data.training)

predicted.ctree <- predict(data.ctree, data.test[,1:13])
real <- data.test[,14]
accuracy.ctree <- mean(real == predicted.ctree)
print(accuracy.ctree)

# Knn
normalize <- normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}


#data.norm <- as.data.frame(lapply(data[c(1,)], normalize))
#data.norm$output = data$output



#knn <- knn(data.training[,1:13], data.test[,1:13], cl=data.training[,14], k = 2, prob = FALSE)
