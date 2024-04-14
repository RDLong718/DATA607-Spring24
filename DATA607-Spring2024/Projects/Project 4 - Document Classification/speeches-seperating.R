# Read Json iinto dataframe
library(jsonlite)

# Read the json file
speeches <- fromJSON("speeches.json")

# Find only speeches by Barack Obama
obama_speeches <- speeches[speeches$president == "Barack Obama",]
# Find only speeches by Donald Trump
trump_speeches <- speeches[speeches$president == "Donald Trump",]

# Make each speech by Obama a single text file
for (i in 1:nrow(obama_speeches)) {
  write.table(obama_speeches$transcript[i], file = paste0("obama_speech_", i, ".txt"), row.names = FALSE, col.names = FALSE)
}
# Make each speech by Trump a single text file
for (i in 1:nrow(trump_speeches)) {
  write.table(trump_speeches$transcript[i], file = paste0("trump_speech_", i, ".txt"), row.names = FALSE, col.names = FALSE)
}



