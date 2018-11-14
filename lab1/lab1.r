setwd("~/Studia/Inteligencja/lab1")
source("funkcjeNormStand.R")

suma <- function(a,b) {
  return(a+b)
}

# zadanie 1
x=c(7,4,2,0,9)
y=c(2,1,5,3,3)
suma_xy = x+y
iloczyn_xy = x*y

#macierze
mat_a = matrix(c(0,2,1,1,6,4,5,0,3), nrow = 3, ncol=3, byrow = TRUE )
mat_b = matrix(c(9,8,7,1,2,7,4,9,2), nrow=3, ncol=3, byrow=TRUE)
il_mat = a %*% b

# zadanie 2
my_data = read.csv("osoby.csv", header=TRUE, sep=',')
imiona = my_data['imie']
kobiety = subset(my_data, plec=='k')
mezczyzni = subset(my_data, wiek>50)
# zapis do pliku mezczyzn starszych niz 50lat
write.csv(mezczyzni, file='osoby2.csv')

# zadanie 3
my_data$wyplata = round(runif(7,2000,5000), 2)
# dodawanie wiersza
# my_data[nrow(my_data) + 1,] = list(nazwisko='Kowalski', imie='Jan', plec='m', wiek=30, wyplata=round(runif(1,5000,7000), 2))
my_data = rbind(my_data, data.frame(nazwisko="Kowalski", imie="Jan", plec='m', wiek=30, wyplata=round(runif(1,2000,5000), 2)))
srednia = mean(my_data$wyplata)
odchylenie = sd(my_data$wyplata)
min_wyplata = min(my_data$wyplata)
max_wyplata = max(my_data$wyplata)
# dodanie kolumny z ustandaryzowanymi wartosciami wyplat
my_data$ustandaryzowane = ((my_data$wyplata-srednia)/odchylenie)
srednia_ustand = mean(my_data$ustandaryzowane)
odchylenie_ustand = mean(my_data$ustandaryzowane)
# dodanie kolumny ze znormalizowanymi wartosciami wyplat
my_data$znormalizowane = ((my_data$wyplata-min_wyplata)/(max_wyplata-min_wyplata))
summary(my_data) # sredni wiek 40.88
