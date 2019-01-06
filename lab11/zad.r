# Needed <- c("SnowballCC", "RColorBrewer", "ggplot2", "wordcloud", "biclust", 
#     "cluster", "igraph", "fpc")
# install.packages(Needed, dependencies = TRUE)

# install.packages("Rcampdf", repos = "http://datacube.wu.ac.at/", type = "source")

library(tm)
library(ggplot2)
library(RColorBrewer)
library(wordcloud)
library(cluster)
library(fpc)
library(RNewsflow)


# cname <- file.path("C:", "Users", "kubar", "Documents", "Projects", "IO", "lab11", "articles")
cname <- file.path("~", "Studia", "Inteligencja", "lab11", "articles")

preprocsessing <- function(docs) {
    docs <- tm_map(docs,removePunctuation)  
    docs <- tm_map(docs, removeNumbers)  
    docs <- tm_map(docs, content_transformer(tolower))

    print(stopwords("english"))
    docs <- tm_map(docs, removeWords, stopwords("english"))   
    docs <- tm_map(docs, removeWords, c("can", "also", "used", "use", "often", "many", "like", "may"))   
    docs <- tm_map(docs, stripWhitespace)

    docs
}

texts <- VCorpus(DirSource(cname))
texts <- preprocsessing(texts)

# Create a document term matrix and transpose it
dtm <- DocumentTermMatrix(texts) 
tdm <- TermDocumentMatrix(texts)   

# Explore your data
freq <- colSums(as.matrix(dtm))
ord <- order(freq)   

# Remove infrequently used words
dtms <- removeSparseTerms(dtm, 0.2) # 20 % empty space max
freq <- sort(colSums(as.matrix(dtms)), decreasing=TRUE)

# Word frequencies as data frame
wf <- data.frame(word = names(freq), freq = freq)

# plotting
plot <- ggplot(wf, aes(x = reorder(word, -freq), y = freq)) +
    geom_bar(stat="identity") +
    theme(axis.text.x = element_text(angle=45, hjust = 1))

term_correl <- findAssocs(dtm, c("computer" , "life", "programming", "language"), corlimit=0.85)

# WORD CLOUDS
set.seed(142)
dark2 <- brewer.pal(6, "Dark2")
# trzeba odpalic w konsoli
wordcloud(names(freq), freq, min.freq = 4, colors=dark2)

# KLASTERYZACJA
d <- dist(t(dtms), method="euclidean")
fit <- hclust(d=d, method="complete")

plot.new()
plot(fit, hang=-1)
groups <- cutree(fit, k=6)   # "k=" defines the number of clusters you are using   
rect.hclust(fit, k=6, border="red") # draw dendogram with red borders around the 6 clusters

# K-Srednie
kfit <- kmeans(d,6)
clusplot(as.matrix(d), kfit$cluster, color=T, shade=T, lines=0)

cos <- documents.compare(dtm, dtm.y = NULL, measure="cosine")
print(cos[cos$x=="genetic-algorithm.txt",])


