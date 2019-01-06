library(neuralnet)
library(nnet)
wd <- file.path("C:", "Users", "kubar", "Documents", "Projects", "IO", "zad_domowe_3")
setwd(wd)



game_data = read.csv("shooter.csv", header=TRUE, sep=',')
# normalize needed column for neural network

normalize <- function(x) {
  if(min(x) == max(x)) return (x)
  return ((x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE)))
}

pos_col = c("myTank.x", "myTank.y", "enemyTank.x", "enemyTank.y", 
            "myBullet1.x", "myBullet1.y","myBullet2.x","myBullet2.y","myBullet3.x", "myBullet3.y",
            "enemyBullet1.x", "enemyBullet1.y","enemyBullet2.x","enemyBullet2.y","enemyBullet3.x", "enemyBullet3.y")

angle_col = c("myTank.rotation", "myTank.cannonRotation", "enemyTank.rotation", "enemyTank.cannonRotation")

velo_col = c("myTank.velocityX", "myTank.velocityY", "enemyTank.velocityX", "enemyTank.velocityY", 
             "myBullet1.velocityX", "myBullet1.velocityY","myBullet2.velocityX","myBullet2.velocityY","myBullet3.velocityX", "myBullet3.velocityY",
             "enemyBullet1.velocityX", "enemyBullet1.velocityY","enemyBullet2.velocityX","enemyBullet2.velocityY","enemyBullet3.velocityX", "enemyBullet3.velocityY")

shoot_col = c("myTank.shootCooldown", "enemyTank.shootCooldown")

norm = game_data
norm[pos_col] = lapply(game_data[pos_col], function(x){x/500})
norm[angle_col] = lapply(game_data[angle_col], function(x){(x%%360)/360})
norm[velo_col] = lapply(game_data[velo_col], normalize)
norm[shoot_col] = lapply(game_data[shoot_col], function(x){x/100})
norm["currentGameTime"] = lapply(game_data["currentGameTime"], function(x){x/40000})


nn <- neuralnet(
  myTank.controls.turnLeft + myTank.controls.turnRight +
    myTank.controls.goForward + myTank.controls.goBack +
    myTank.controls.shoot + myTank.controls.cannonLeft +
    myTank.controls.cannonRight ~ 
    myTank.x + myTank.y + myTank.rotation + myTank.cannonRotation +
    myTank.velocityX + myTank.velocityY + myTank.shootCooldown +
    enemyTank.x + enemyTank.y + enemyTank.rotation + enemyTank.cannonRotation +
    enemyTank.velocityX + enemyTank.velocityY + enemyTank.shootCooldown +
    currentGameTime,
  data = norm, hidden=6, threshold = 0.8, lifesign = "full", stepmax = 1e7
)

results = nn[10]

bias1 = results[["weights"]][[1]][[1]][1,]
weights1 = results[["weights"]][[1]][[1]][-1,]
bias2 = results[["weights"]][[1]][[2]][1,]
weights2 = results[["weights"]][[1]][[2]][-1,]

printW <- function(x) {
  paste0(x,collapse=',')
}