# init

libs <- c("tm","plyr","class")
lapply(libs, require, character.only = TRUE)

# Set options
options(stringsAsFactors = FALSE)

# Set paramaters

speaker <- c("obama","trump")
pathname <- "C:/Users/rdlon/OneDrive/Documents/Education/CUNY School of Professional Stuides/DATA 607/DATA607-Spring2024/Projects/Project 4 - Document Classification/speeches"


# clean text
cleanCorpus <- function(corpus){
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removeWords, stopwords("english"))
  corpus <- tm_map(corpus, stripWhitespace)
  return(corpus)
}

# Build TDM
generateTDM <- function(name, path){
  s.dir <- sprintf("%s/%s", path, name)
  s.cor <- Corpus(DirSource(directory = s.dir, encoding = "UTF-8"))
  s.cor.cl <- cleanCorpus(s.cor)
  s.tdm <- TermDocumentMatrix(s.cor.cl)
  
  s.tdm <- removeSparseTerms(s.tdm, 0.7)
  result <- list(name = name, tdm = s.tdm)
}

tdm <- lapply(speaker, generateTDM, path = pathname)


# attach name

bind_speaker_to_TDM <- function(tdm){
  s.mat <- t(data.matrix(tdm[["tdm"]]))
  s.df <- as.data.frame(s.mat, stringsAsFactors = FALSE)
  
  s.df <- cbind(s.df, rep(tdm[["name"]], nrow(s.df)))
  colnames(s.df)[ncol(s.df)] <- "targetspeaker"
  return(s.df)
}

speaker_tdm <- lapply(tdm, bind_speaker_to_TDM)
str(speaker_tdm)

# stack
tdm.stack <- do.call(rbind.fill, speaker_tdm)
tdm.stack[is.na(tdm.stack)] <- 0

nrow(tdm.stack)
ncol(tdm.stack)  

# hold-out
train.idx <- sample(nrow(tdm.stack), ceiling(nrow(tdm.stack)* 0.7))
test.idx <- (1:nrow(tdm.stack))[-train.idx]
head(test.idx)
head(train.idx)
  
# model - KNN
tdm.speaker <- tdm.stack[,"targetspeaker"]
tdm.stack.nl <- tdm.stack[,!(colnames(tdm.stack)%in% "targetspeaker")]

knn.pred <- knn(tdm.stack.nl[train.idx, ], tdm.stack.nl[test.idx, ], tdm.speaker[train.idx])

# accuracy

conf.mat <- table("Predictions" = knn.pred, "Actual" = tdm.speaker[test.idx])
conf.mat  
(accuracy <- sum(diag(conf.mat)) / length(test.idx) * 100)

  
  
  
  








