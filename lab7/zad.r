# zadanie 1
x = c(1,2,3,5,5,7,9)
y = c(3,5,2,2,6,4,5)


plot(x, y,ylim=c(min(y)-1,max(y)+1), xlim=c(min(x)-1,max(x)+1), pch=0, col="grey")
ctr = data.frame(x = c(1,8),y = c(6,1))

points(ctr$x[1], ctr$y[1], col=2, pch=15)
points(ctr$x[2], ctr$y[2], col=3, pch=15)

euclidean <- function(a, b){
  return(sqrt((b[1]-a[1])^2 + (b[2]-a[2])^2))
}
# universal, make matrix with distances between centers and points
# quantity of columns = centroids
calculate_distances <- function(x, y, ctr){
  dist_mx = matrix(nrow=length(x), ncol=length(ctr$x))
  for (i in 1:length(x)) {
    point = c(x[i],y[i])
    for(j in 1:length(ctr$x)){
      dist_mx[i,j] = euclidean(point,c(ctr[j,1], ctr[j,2]))
    }
  }
  print(dist_mx)
  return(dist_mx)
}

assing_points <- function(dist) {
  matches = list()
  # initialize vectors in list
  for(i in 1:length(dist[,1])){
    center = as.character(which.min(dist[i,]))
    matches[[center]] <- c(matches[[center]], i) #something wrong
  }
  print(matches)
  return(matches)
}

new_center <- function(divided){
  for (i in 1:length(ctr$x)) {
    ctr$x[i] <<- mean(divided[[i]]$V1) 
    ctr$y[i] <<- mean(divided[[i]]$V2) 
  }
}

make_plot <- function(divided){
  plot(divided[[1]]$V1, divided[[1]]$V2,ylim=c(min(y)-1,max(y)+1), xlim=c(min(x)-1,max(x)+1), pch=0, col=2)
  points(ctr$x[1], ctr$y[1], col=2, pch=15)
  for (i in 2:length(ctr$x)) {
    points(divided[[i]]$V1, divided[[i]]$V2, col=i+1, pch=0)
    points(ctr$x[i], ctr$y[i], col=i+1, pch=15)
  }
}

fill_divided <- function(match) {
  divided = list()
  for (i in 1:length(ctr$x)) {
    divided[[i]] <- as.data.frame(cbind(x[match[[i]]], y[match[[i]]]))
  }
  return(divided)
}

algorithm <- function(iterations) {
  for (i in 1:iterations) {
    distances = calculate_distances(x,y,ctr)
    match = assing_points(distances)
    divided = fill_divided(match)
    print(divided)
    new_center(divided)
    make_plot(divided)
  }
}

algorithm(3)