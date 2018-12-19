A = data.frame(
  x = seq(from=0,to=10,by=0.01)
)

A$y = ifelse(A$x <= 4 & A$x > 2, 0, 1)

plot(A, type="line")

B = data.frame(
  x = seq(1, 10, 0.01)
)

if(B$x <= 1 | B$x > 6){
  B$y = 0
} else if(B$x > 3 & B$x <=5) {
  B&y = 1
} else if(B$x > 1 & B$x <=3) {
  B$y = 0.5*B$x-0.5
} else if(B$x > 5 & B$x <=6) {
  B&y = -x + 6
}