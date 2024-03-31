library(tidyverse)
library(tidytext)
library(janeaustenr)
library(gutenbergr)
library(scales)

text <- c(
  "Because I could not stop for Death -",
  "He kindly stopped for me -",
  "The Carriage held but just Ourselves -",
  "and Immortality"
)
text

# Create a tibble with the text
text_df <- tibble(line = 1:4, text = text)
text_df

# Split the text into words
text_df |> 
  unnest_tokens(word, text)

# Tidying the works of Jane Austen
original_books <-  austen_books() |> 
  group_by(book) |> 
  mutate(linenumber =  row_number(),
         chapter = cumsum(str_detect(text, regex("^chapter [\\divxlc]", ignore_case = TRUE)))) |>
  ungroup()

original_books

# Unnest the text
tidy_books <- original_books |> 
  unnest_tokens(word, text)
tidy_books

# Remove stop words
data(stop_words)

tidy_books <- tidy_books |> 
  anti_join(stop_words)

tidy_books

# Count the words
tidy_books |> 
  count(word, sort = TRUE) |> 
  filter(n > 600) |> 
  mutate(word = reorder(word, n)) |>
  ggplot(aes(n, word)) +
  geom_col() +
  labs(y = NULL)

# Sentiment analysis of gutenbergr books
library(gutenbergr)
my_mirror <- "http://mirror.csclub.uwaterloo.ca/gutenberg/"
hgwells <- gutenberg_download(c(35,36,5230,159), mirror = my_mirror)
hgwells

# Split the text into words
tidy_hgwells <- hgwells |> 
  unnest_tokens(word, text) |> 
  anti_join(stop_words)
tidy_hgwells

# Count the most common words in these novels
tidy_hgwells |> 
  count(word, sort = TRUE)

# Lets get the well-known works of the Bronte sisters
bronte <- gutenberg_download(c(1260, 768, 969, 9182, 767), mirror = my_mirror)
bronte
tidy_bronte <- bronte |> 
  unnest_tokens(word, text) |> 
  anti_join(stop_words)
tidy_bronte

# Count the most common words in these novels
tidy_bronte |> 
  count(word, sort = TRUE)

# Now, let’s calculate the frequency for each word for the works of Jane Austen, the Brontë sisters, and H.G. Wells by binding the data frames together
frequency <- bind_rows(mutate(tidy_bronte, author = "Bronte Sisters"),
                       mutate(tidy_hgwells, author = "H.G. Wells"),
                       mutate(tidy_books, author = "Jane Austen")) |> 
  mutate(word = str_extract(word, "[a-z']+")) |> 
  count(author, word) |> 
  group_by(author) |> 
  mutate(proportion = n / sum(n)) |> 
  select(-n) |> 
  pivot_wider(names_from = author, values_from = proportion) |> 
  pivot_longer(`Bronte Sisters`:`H.G. Wells`, names_to = "author", values_to = "proportion")
frequency

# Plot the frequency of the words
ggplot(frequency, aes(x = proportion, y = `Jane Austen`, 
                      color = abs(`Jane Austen` - proportion))) +
  geom_abline(color = "gray40", lty = 2) +
  geom_jitter(alpha = 0.1, size = 2.5, width = 0.3, height = 0.3) +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1.5) +
  scale_x_log10(labels = percent_format()) +
  scale_y_log10(labels = percent_format()) +
  scale_color_gradient(limits = c(0, 0.001), 
                       low = "darkslategray4", high = "gray75") +
  facet_wrap(~author, ncol = 2) +
  theme(legend.position="none") +
  labs(y = "Jane Austen", x = NULL)

# Correlate the frequency of words
cor.test(data = frequency[frequency$author == "Bronte Sisters",],
         ~ proportion + `Jane Austen`)

cor.test(data = frequency[frequency$author == "H.G. Wells",], 
         ~ proportion + `Jane Austen`)

# Load Charles Darwins top books using gutenbergr
darwin_books <- gutenberg_download(c(944, 1228, 2300, 1227), mirror = my_mirror)
darwin_books


tidy_darwin <- darwin_books |> 
  unnest_tokens(word, text) |> 
  anti_join(stop_words)

tidy_darwin |> 
  count(word, sort = TRUE)


# Original Darwin books 
darwin_books <- darwin_books |> 
  group_by(gutenberg_id) |> 
  mutate(linenumber = row_number(),
         chapter = cumsum(str_detect(text, regex("^chapter [\\divxlc]", ignore_case = TRUE))),
         book = case_when(
           gutenberg_id == 944 ~ "The Voyage of the Beagle",
           gutenberg_id == 1228 ~ "On the Origin of Species",
           gutenberg_id == 2300 ~ "The Descent of Man, and Selection in Relation to Sex",
           gutenberg_id == 1227 ~ "The Expression of the Emotions in Man and Animals"
         )) |>
  ungroup() |> 
  select(-gutenberg_id) |> 
  unnest_tokens(word,text)

darwin_books

# delete guttenberg_id column


# In darwin_books, if the guttenberg_id is 944, then the book is "The Voyage of the Beagle", if the guttenberg_id is 1228, then the book is "On the origin of species", if the guttenberg_id is 2300, then the book is "The Descent of Man, and Selection in Relation to Sex", if the guttenberg_id is 1227, then the book is "The Expression of the Emotions in Man and Animals"
darwin_books <- darwin_books |> 
  mutate(book = case_when(
    gutenberg_id == 944 ~ "The Voyage of the Beagle",
    gutenberg_id == 1228 ~ "On the Origin of Species",
    gutenberg_id == 2300 ~ "TThe Descent of Man, and Selection in Relation to Sex",
    gutenberg_id == 1227 ~ "The Expression of the Emotions in Man and Animals"
  ))
darwin_books

# Show the gutenber_id 1227
darwin_books |> 
  filter(gutenberg_id == 1227)



library(janeaustenr)
austen_books()

#example for loop
for (i in 1:10) {
  print(i)
}

# loop this for the gi dictionary also
huliu <- data_dictionary_HuLiu %>% as.list()
huliu_pos <- data.frame(huliu[1], sentiment = "positive")
names(huliu_pos)[1] <- "word"
huliu_neg <- data.frame(huliu[2], sentiment = "negative")
names(huliu_neg)[1] <- "word"
huliu <- rbind(huliu_pos, huliu_neg) # 6789 words
huliu$word <- lemmatize_words(huliu$word)
huliu <- huliu %>% distinct() # 5644 words
huliu$dict <- "huliu"

print(huliu)
(gi)
get_sentiments("nrc")
get_sentiments("bing")

huliu
gi

huliu |> 
  filter(sentiment %in% c("positive", "negative")) |>
  count(sentiment) |> 
  mutate(ratio = n / sum(n))








