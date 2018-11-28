library(arules)
titanic <- load("titanic.raw.rdata")

rules <- apriori(titanic.raw,
                 parameter = list(minlen=2, supp=0.005, conf=0.8),
                 appearance = list(rhs=c("Survived=No", "Survived=Yes"), default="lhs"),
                 control = list(verbose=F)
                 )
rules.sorted <- sort(rules, by="lift")
