library(party)
library(class)
library(e1071)
library(randomForest)
library(ggplot2)
library(arules)
library(data.table)


# Wybrana baza Heart Disease https://archive.ics.uci.edu/ml/datasets/Heart+Disease
# G��wna baza danych zawiera�a, a� 76 kolumn. Jednak specjali�ci od machine learningu
# pracowali wy��cznie na bazie Clevaland, kt�ra zawiera tylko 14 z 76 pocz�tkowych kolumn

# Kolumna "num" nadaje si� na klas�.
# Zawiera warto�ci liczbow� od 0 (choroba nie wyst�puje) do 4.
# Zmienili�em zakres warto�ci na binarny: 0 (zdrowy), 1 (chory), dzi�ki temu kolumna nadaje si� na klas�

get_tpr <- function(t){
  # t - confusion matrix, TP/TP+FN
  tpr = t[1]/(t[1]+t[2])
  return(tpr)
}

get_fpr <- function(t) {
  # FP/FP+TN
  tpr = t[3]/(t[3]+t[4])
  return(tpr)
}

data = read.csv("processed.cleveland.csv", header=TRUE, sep=',')

# W bazie znajduj� sie troche pustych warto�ci w kolumnach, oznaczone s� "?"
# kt�re zaburza�y by przewidywanie wynik�w
# Szukamy ich i oznaczami jako bez warto�ci, nast�pnie usuwam te wiersze z bazy

data[data == "?"] <- NA
data <- na.omit(data)

# Algorytm knn wymaga, by wszystkie kolumny,
# by�y numeryczne, a kolumna klasowa byla factorem
data$ca <- as.character(data$ca) 
data$ca <- as.numeric(data$ca)
data$thal <- as.numeric(data$thal)
data$num = ifelse(data$num == 0, "No", "Yes")
data$num = as.factor(data$num)

# dzielenie na zbior treningowy i testowy 80% do 20%
set.seed(1234)
ind <- sample(2, nrow(data), replace=TRUE, prob=c(0.8,0.2))
data.train <- data[ind==1, 1:14]
data.test <- data[ind==2, 1:14]
real <- data.test[,14]


# DRZEWA (ctree)
# =====================

# Utworzenie drzewa
ctree <- ctree(num ~ ., data = data.train)

ctree.predicted <- predict(ctree, data.test[,1:13])
ctree.confMat <- table(ctree.predicted, real)[2:1, 2:1]
ctree.accuracy <- mean(real == ctree.predicted)
ctree.tpr <- get_tpr(ctree.confMat)
ctree.fpr <- get_fpr(ctree.confMat)

print(ctree.confMat)
print(ctree.tpr)
print(ctree.fpr)
print(ctree.accuracy)
# =====================


# NAIVE BAYES (nb)
# =====================

nb <- naiveBayes(num ~ ., data=data.train)
nb.predicted <- predict(nb, newdata=data.test)
nb.confMat <- table(nb.predicted, real)[2:1, 2:1]
nb.accuracy <- mean(real == nb.predicted)
nb.tpr <- get_tpr(nb.confMat)
nb.fpr <- get_fpr(nb.confMat)

print(nb.confMat)
print(nb.tpr)
print(nb.fpr)
print(nb.accuracy)
# =====================

# Knn (knn)
# =====================

# Funkcja do normalizacji
normalize <- normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

# Normalizacja danych
data.norm <- as.data.frame(lapply(data[1:13], normalize))
data.norm$num = data$num
data.norm.train <- data.norm[ind==1,]
data.norm.test <- data.norm[ind==2,]


# Lista z dok�adno�ci� zale�n� od podanego k
knn.list <- data.frame(k = numeric(), accuracy = numeric())

for (i in 1:14) {
  temp_knn <- knn(data.norm.train[1:13], data.norm.test[1:13], cl=data.norm.train$num, k = i, prob = FALSE)
  knn.list[nrow(knn.list)+1,] <- c(i, mean(real==temp_knn))
}

# Szukanie k z najwi�ksz� dok�adno�ci�
knn.kWithMaxAccuracy = knn.list[which.max(knn.list$accuracy),1] 
knn <- knn(data.norm.train[1:13], data.norm.test[1:13], cl=data.norm.train$num, k = knn.kWithMaxAccuracy, prob = FALSE)

knn.confMat <- table(knn, real)[2:1, 2:1]
knn.accuracy <- mean(real == knn)
knn.tpr <- get_tpr(knn.confMat)
knn.fpr <- get_fpr(knn.confMat)

print(knn.confMat)
print(knn.tpr)
print(knn.fpr)
print(knn.accuracy)
# =====================

# RANDOM FOREST (rf)
# =====================

rf <- randomForest(num ~ ., data=data.train, mtry=1, importance = TRUE)
var_importance <- varImpPlot(rf)
rf.predicted <- predict(rf, data.test)
rf.confMat <- table(rf.predicted, real)[2:1, 2:1]
rf.accuracy <- mean(real == rf.predicted)
rf.tpr <- get_tpr(rf.confMat)
rf.fpr <- get_fpr(rf.confMat)

print(rf.confMat)
print(rf.tpr)
print(rf.fpr)
print(rf.accuracy)
# =====================

# ############################
# ############################
# ############################

# Rozszyfrowa� w jakiej zale�no�ci od TPR i FPR s� miary FNR i TNR. Poda�
# te wzory w sprawozdaniu.
# FNR = 1 - TPR
# TNR = 1 - FPR
# =============================================================================
# Udzieli� odpowiedzi czym jest u Pa�stwa b��d pierwszego i drugiego
# rodzaju. Jak maj� si� oba rodzaje b��d�w do TPR, FPR, TNR, FNR. Im
# wi�cej b��d�w pierwszego rodzaju tym wi�ksze jest co? Co z b��dami
# drugiego rodzaju?
# .............................................................................
# B��d pierwszego rodzaju to ludzie zdrowi, b��dnie zdiagnozowania jako chorzy
# B��d drugiego rz�du to ludzie chorzy, b��dnie zdiagnozowania jako zdrowi
# Im wi�cej b��d�w pierwszego rodzaju tym mniejszy TNR, a tym wi�kszy FPR
# Im wi�cej b��d�w drugiego rodzaju tym mniejszy TPR, a tym wi�kszy FNR
# =============================================================================
# Pytanie filozoficzne, na kt�re r�wnie� prosz� udzieli� odpowiedzi: kt�ry z
# b��d�w w Pa�stwa bazie jest gorszy do pope�nienia: pierwszego czy drugiego
# rodzaju? Odpowied� uzasadni�.
# .............................................................................
# Uwa�am, �e b��d drugiego rodzaju jest gorszy do pope�nienia. Na przyk�adzie
# wykorzystanej przeze mnie bazy: ludzie, kt�rzy na prawd� s� chorzy zostan�
# zakwalifikowania jako zdrowi i nie b�d� mieli szans na leczenie, co mo�e spowodowa�
# zgon. Przy b��die pierwszego rodzaju, zdrowy pacjent po dok�adnych badaniach zostanie
# odes�any do domu.

# Dla ka�dego z czterech klasyfikator�w obliczy� par� (FPR,TPR) i zaznaczy�
# jako punkt na wykresie
rocSpace = data.frame(
 "FPR" = c(ctree.fpr, nb.fpr, knn.fpr, rf.fpr),
 "TPR" = c(ctree.tpr, nb.tpr, knn.tpr, rf.tpr),
 "Class" = c("DRZEWO", "Naive Bayes", "kNN", "Random Forest")
)

# Wykres
roc_plot <- ggplot(rocSpace, aes(x = FPR, y = TPR, color = Class)) + geom_point(size=3)

# ##############################
# #GRUPOWANIE METODA K-SREDNICH#
# ##############################

data.log <- log(data[,c(1:13)])

replace_inf <- function(x) {
  x[is.infinite(x)] <- NA
  replace_value <- mean(x, na.rm = TRUE)
  x[is.na(x)] <- replace_value
}

replace_means <- sapply(data.log, replace_inf)
replace_means <- as.data.frame(replace_means)

data.log$oldpeak[is.infinite(data.log$oldpeak)] <- replace_means["oldpeak",]
data.log$restecg[is.infinite(data.log$restecg)] <- replace_means["restecg",]
data.log$ca[is.infinite(data.log$ca)] <- replace_means["ca",]

data.log$sex = data$sex
data.log$fbs = data$fbs
data.log$exang = data$exang

data.stand <- scale(data.log, center=TRUE)
data.pca <- prcomp(data.stand)
data.final <- predict(data.pca)[,1:2]
data.final <- as.data.frame(data.final)

kmeans <- kmeans(data.final, 2)
data.final$cluster = factor(kmeans$cluster)
centers = as.data.frame(kmeans$centers)


kmeans.pred.plot <- ggplot(data.final, aes(x=PC1, y=PC2, color=cluster)) +
  geom_point() +
  geom_point(data=centers, aes(x=PC1,y=PC2, color='Center')) + 
  geom_point(data=centers, aes(x=PC1,y=PC2, color='Center'), size=52, alpha=.3, show.legend=FALSE)

kmeans.real.plot <- ggplot(data.final, aes(x=PC1, y=PC2, color=data$num)) +
  geom_point() 


# ####################
# #REGULY ASOCJACYJNE#
# ####################

data.rules <- data.table(data)
data.rules$age = as.factor(data.rules$age)
data.rules$sex = ifelse(data.rules$sex == 1, "Male", "Female")
data.rules$sex = as.factor(data.rules$sex)
data.rules$cp = as.factor(data.rules$cp)
data.rules$trestbps = as.factor(data.rules$trestbps)
data.rules$chol = as.factor(data.rules$chol)
data.rules$fbs = data.rules$fbs == 1
data.rules$restecg = as.factor(data.rules$restecg)
data.rules$thalach = as.factor(data.rules$thalach)
data.rules$exang = data.rules$exang == 1
data.rules$oldpeak = as.factor(data.rules$oldpeak)
data.rules$slope = as.factor(data.rules$slope)
data.rules$ca = as.factor(data.rules$ca)
data.rules$thal = as.factor(data.rules$thal)






data.rules <- as(data.rules, 'transactions')


rules <- apriori(data.rules, 
                 parameter = list(minlen=2, supp=0.005, conf=0.8),
                 appearance = list(rhs=c("num=No", "num=Yes"), default="lhs"),
                 control = list(verbose=F)
                 )
rules.sorted <- sort(rules, by="lift")
subset.matrix <- is.subset(rules.sorted, rules.sorted)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- FALSE
redundant <- colSums(subset.matrix, na.rm=T) >= 1
rules.pruned <- rules.sorted[!redundant]

print(inspect(rules.pruned))








