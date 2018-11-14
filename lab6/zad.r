# Useful links: https://www.kaggle.com/nazar969/iris-dataset

# zadanie 1 (A)
# Klasyfikacja do 1-najblizszego sasiada
# (2.7, 6) - versicolor
# (5, 7) - virginica
# (7, 3.5) - virginica

# Klasyfikacja do 3-najblizszych sasiadow
# (2.7, 6) - versicolor
# (5, 7) - virginica
# (7, 3.5) - versicolor
library(class)

normalize <- function(x) {
    return ((x - min(x)) / (max(x) - min(x)))
}

# normalizacja (B)
iris.norm <- as.data.frame(lapply(iris[1:4], normalize))
iris.norm$Species = irisdb$Species
# Podzielenie zbiorow (C)
set.seed(1234)
ind <- sample(2, nrow(iris.norm), replace=TRUE, prob=c(0.67, 0.33))
iris.norm.training <-iris.norm[ind==1, 1:5]
iris.norm.test <-iris.norm[ind==2, 1:5]
# Algorytm Knn (D)
knn.3 <- knn(iris.norm.training[,1:4], iris.norm.test[,1:4], cl=iris.norm.training[,5], k = 3, prob=FALSE)
# Dokonaj ewaluacji klasyfikatora i wyświetl macierz błędu, oraz jego dokładność. (E)
predicted <- knn.3
real <- iris.norm.test[,5]
conf.matrix <- table(predicted, real)
accuracy <- sum(diag(conf.matrix))/sum(conf.matrix)
print(conf.matrix)
print(accuracy)
# Poprawnosc jest taka sama jak w drzewach decyzyjnych (F)

# Zadanie 2
osoby <- data.frame(
    age = c('31..40', '>40', '>40', '>40', '31..40', '<=30', '<=30'),
    income = c('high', 'medium', 'high', 'low', 'low', 'medium', 'low'),
    student = c(FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, TRUE),
    credit.rating = c('fair','fair','excellent','excellent','excellent','fair','fair'),
    buys = c(TRUE, TRUE, TRUE, FALSE, TRUE, FALSE, FALSE)
)

#krok 2
tAge = nrow(osoby[osoby$age == '>40' & osoby$buys==TRUE,])/nrow(osoby[osoby$buy == TRUE,]) # (wśród osób kupujących komputer liczymy osoby starsze niż 40)
fAge = nrow(osoby[osoby$age == '>40' & osoby$buys==FALSE,])/nrow(osoby[osoby$buy == FALSE,]) # (jest jedna osoba 40+ wśród 3 osób niekupujących komputera)
tIncome = nrow(osoby[osoby$income == 'low' & osoby$buys==TRUE,])/nrow(osoby[osoby$buy == TRUE,])
fIncome = nrow(osoby[osoby$income == 'low' & osoby$buys==FALSE,])/nrow(osoby[osoby$buy == FALSE,])
tStudent = nrow(osoby[osoby$student == FALSE & osoby$buys==TRUE,])/nrow(osoby[osoby$buy == TRUE,])
fStudent = nrow(osoby[osoby$student == FALSE & osoby$buys==FALSE,])/nrow(osoby[osoby$buy == FALSE,])
tCredit = nrow(osoby[osoby$credit.rating == 'fair' & osoby$buys==TRUE,])/nrow(osoby[osoby$buy == TRUE,])
fCredit = nrow(osoby[osoby$credit.rating == 'fair' & osoby$buys==FALSE,])/nrow(osoby[osoby$buy == FALSE,])

# krok 3
probT = tAge * tIncome * tStudent * tCredit
probF = fAge * fIncome * fStudent * fCredit

# krok 4
bayesT = probT * (nrow(osoby[osoby$buy == TRUE,]))/nrow(osoby)
bayesF = probF * (nrow(osoby[osoby$buy == FALSE,]))/nrow(osoby)
result = max(bayesT, bayesF)

print(result)
