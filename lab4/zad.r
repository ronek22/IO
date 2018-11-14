setwd("~/Studia/Inteligencja/lab4")
library(editrules)
library(deducorrect)
dirty.iris <- read.csv("dirty_iris.csv", header=TRUE, sep=",")
dirty.iris <- subset(dirty.iris, is.finite(dirty.iris$Sepal.Length) & is.finite(dirty.iris$Sepal.Width) & is.finite(dirty.iris$Petal.Length) & is.finite(dirty.iris$Petal.Width))
correct_rows = nrow(dirty.iris)

desired_species = c("setosa", "versicolor", "virginica")
E <- editset(c("Sepal.Length <= 30", "Species %in% desired_species",
               "Petal.Length >= 2*Petal.Width", 
               "Sepal.Length > Petal.Length",
                "Sepal.Length > 0",
                "Sepal.Width > 0",
                "Petal.Length > 0",
                "Petal.Width > 0"))
ve <- violatedEdits(E, dirty.iris)
failed_rows <- data.frame(ve[which(apply(ve, 1, any)), ])
correct <- correct_rows - nrow(failed_rows)
iris_with_wrong_ratio = failed_rows$num2 == TRUE

rules <- correctionRules("corrections.txt")
cor <- correctWithRules(rules, dirty.iris)




