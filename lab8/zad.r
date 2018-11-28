zakupy <- data.frame(
  maslo = c(1,0,1,0,0,0,1,0,1,1),
  chleb = c(1,1,1,0,1,1,1,1,1,1),
  ser = c(0,1,1,0,0,0,0,0,1,0),
  piwo = c(0,0,0,1,1,1,1,1,1,1),
  czipsy = c(0,0,0,1,0,1,1,1,0,1)
)


supp_and_conf <- function(data, lhs, rhs, name){
  rows = nrow(data)
  support <- eval(substitute(lhs & rhs), data)
  support <- nrow(data[support,])/rows
  
  conf <- eval(substitute(lhs), data)
  conf <- nrow(data[conf,])/rows
  conf <- support/conf
  
  return(list(name, support,conf))
}

perform_exercise1 <- function(){
  df <- data.frame(0,0,0)
  names(df) <- c("Name", "Support", "Confidence")
  
  df[nrow(df),] = supp_and_conf(zakupy, chleb==1,piwo==1 & czipsy==1,"A2")
  df[nrow(df) + 1,] = supp_and_conf(zakupy, piwo==1,czipsy==1, "A3")
  df[nrow(df) + 1,] = supp_and_conf(zakupy, czipsy==1,piwo==1, "A4")
  df[nrow(df) + 1,] = supp_and_conf(zakupy, maslo==1 & ser==1, chleb==1, "A5")
  return(df)
}

measurments <- perform_exercise1()
print(measurments)


