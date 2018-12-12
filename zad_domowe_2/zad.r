library(party)
library(class)
library(e1071)
library(randomForest)
library(ggplot2)
library(arules)
library(data.table)


# Wybrana baza Heart Disease https://archive.ics.uci.edu/ml/datasets/Heart+Disease
# G³ówna baza danych zawiera³a, a¿ 76 kolumn. Jednak specjaliœci od machine learningu
# pracowali wy³¹cznie na bazie Clevaland, która zawiera tylko 14 z 76 pocz¹tkowych kolumn

# Kolumna "num" nadaje siê na klasê.
# Zawiera wartoœci liczbowê od 0 (choroba nie wystêpuje) do 4.
# Zmienili³em zakres wartoœci na binarny: 0 (zdrowy), 1 (chory), dziêki temu kolumna nadaje siê na klasê

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

# W bazie znajduj¹ sie troche pustych wartoœci w kolumnach, oznaczone s¹ "?"
# które zaburza³y by przewidywanie wyników
# Szukamy ich i oznaczami jako bez wartoœci, nastêpnie usuwam te wiersze z bazy

data[data == "?"] <- NA
data <- na.omit(data)

# Algorytm knn wymaga, by wszystkie kolumny,
# by³y numeryczne, a kolumna klasowa byla factorem
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


# Lista z dok³adnoœci¹ zale¿n¹ od podanego k
knn.list <- data.frame(k = numeric(), accuracy = numeric())

for (i in 1:14) {
  temp_knn <- knn(data.norm.train[1:13], data.norm.test[1:13], cl=data.norm.train$num, k = i, prob = FALSE)
  knn.list[nrow(knn.list)+1,] <- c(i, mean(real==temp_knn))
}

# Szukanie k z najwiêksz¹ dok³adnoœci¹
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

# Rozszyfrowaæ w jakiej zale¿noœci od TPR i FPR s¹ miary FNR i TNR. Podaæ
# te wzory w sprawozdaniu.
# FNR = 1 - TPR
# TNR = 1 - FPR
# =============================================================================
# Udzieliæ odpowiedzi czym jest u Pañstwa b³¹d pierwszego i drugiego
# rodzaju. Jak maj¹ siê oba rodzaje b³êdów do TPR, FPR, TNR, FNR. Im
# wiêcej b³êdów pierwszego rodzaju tym wiêksze jest co? Co z b³êdami
# drugiego rodzaju?
# .............................................................................
# B³¹d pierwszego rodzaju to ludzie zdrowi, b³êdnie zdiagnozowania jako chorzy
# B³¹d drugiego rzêdu to ludzie chorzy, b³êdnie zdiagnozowania jako zdrowi
# Im wiêcej b³êdów pierwszego rodzaju tym mniejszy TNR, a tym wiêkszy FPR
# Im wiêcej b³êdów drugiego rodzaju tym mniejszy TPR, a tym wiêkszy FNR
# =============================================================================
# Pytanie filozoficzne, na które równie¿ proszê udzieliæ odpowiedzi: który z
# b³êdów w Pañstwa bazie jest gorszy do pope³nienia: pierwszego czy drugiego
# rodzaju? OdpowiedŸ uzasadniæ.
# .............................................................................
# Uwa¿am, ¿e b³¹d drugiego rodzaju jest gorszy do pope³nienia. Na przyk³adzie
# wykorzystanej przeze mnie bazy: ludzie, którzy na prawdê s¹ chorzy zostan¹
# zakwalifikowania jako zdrowi i nie bêd¹ mieli szans na leczenie, co mo¿e spowodowaæ
# zgon. Przy b³êdie pierwszego rodzaju, zdrowy pacjent po dok³adnych badaniach zostanie
# odes³any do domu.

# Dla ka¿dego z czterech klasyfikatorów obliczyæ parê (FPR,TPR) i zaznaczyæ
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








