library(arules)
#library(arulesViz)
setwd("~/Studia/Inteligencja/lab8")

titanic <- load("titanic.raw.rdata")

rules <- apriori(titanic.raw,
                 parameter = list(minlen=2, supp=0.005, conf=0.8),
                 appearance = list(rhs=c("Survived=No", "Survived=Yes"), default="lhs"),
                 control = list(verbose=F)
)
rules.sorted <- sort(rules, by="lift")


subset.matrix <- is.subset(rules.sorted, rules.sorted)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- FALSE
redundant <- colSums(subset.matrix, na.rm=T) >= 1
rules.pruned <- rules.sorted[!redundant]

print(inspect(rules.pruned))