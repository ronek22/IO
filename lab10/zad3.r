library(sets)
sets_options("universe", seq(from=0, to=40, by=0.1))

variables <- set(
  bmi = fuzzy_partition(
      varnames = c(niedow = 9.25, zdro = 21.75,nadw = 27.5, otyl = 35),
      sd = 3.0
    ),
  a1c = fuzzy_partition(
      varnames = c(nisk = 4, norm = 5.25, wys = 7),
      FUN = fuzzy_cone, radius = 5
  ),
  rating = fuzzy_partition(
    varnames = c(odm = 10, stand = 5, pref = 1),
    FUN = fuzzy_cone, radius = 5
  ),
  bp = fuzzy_partition(
    varnames = c(norm = 0, mnadcis = 10, nadcis = 20,dnadci = 30), 
    sd = 2.5
  )
)

rules <-
  set(
    fuzzy_rule(bmi %is% niedow || bmi %is% otyl || a1c %is% nisk, rating %is% odm),
    fuzzy_rule(bmi %is% nadw || a1c %is% nisk || bp %is% mnadcis, rating %is% stand),
    fuzzy_rule(bmi %is% zdro && a1c %is% norm && bp %is% norm, rating %is% pref)
  )

system <- fuzzy_system(variables, rules)
print(system)
fi <- fuzzy_inference(system, list(bmi = 29, a1c=5, bp=20))

result <- gset_defuzzify(fi, "centroid")




  