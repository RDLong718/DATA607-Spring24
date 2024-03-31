library(tidytext)
library(janeaustenr)
library(wordcloud)
library(reshape2)


# get_sentimnets() allows us to get specific sentiment lexicons
get_sentiments("afinn")
get_sentiments("bing")
get_sentiments("nrc")


# What are the most common joy words in Emma?
tidy_books <- austen_books() |>
  group_by(book) |>
  mutate(linenumber =  row_number(),
         chapter = cumsum(str_detect(
           text, regex("^chapter [\\divxlc]", ignore_case = TRUE)
         ))) |>
  ungroup() |>
  unnest_tokens(word, text)


# First, let’s use the NRC lexicon and filter() for the joy words. 
nrc_joy <- get_sentiments("nrc") |> 
  filter(sentiment == "joy")

tidy_books |>
  filter(book == "Emma") |>
  inner_join(nrc_joy) |>
  count(word, sort = TRUE)




# Small sections of text may not have enough words in them to get a good estimate of sentiment while really large sections can wash out narrative structure

jane_austen_sentiment <- tidy_books |> 
  inner_join(get_sentiments("bing")) |> 
  count(book, index = linenumber %/% 80, sentiment) |> 
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) |>
  mutate(sentiment = positive - negative) |> 
  ggplot(aes(index, sentiment, fill = book)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~book, ncol = 2, scales = "free_x")

jane_austen_sentiment


# Let’s use all three sentiment lexicons and examine how the sentiment changes across the narrative arc of Pride and Prejudice.
pride_prejudice <- tidy_books |> 
  filter(book == "Pride & Prejudice")

pride_prejudice

# Now, we can use inner_join() to calculate the sentiment in different ways
# Let’s again use integer division (%/%) to define larger sections of text that span multiple lines, and we can use the same pattern with count(), pivot_wider(), and mutate() to find the net sentiment in each of these sections of text.

afinn <- pride_prejudice |> 
  inner_join(get_sentiments("afinn")) |>
  group_by(index = linenumber %/% 80) |>
  summarise(sentiment = sum(value)) |>
  mutate(method = "AFINN")

afinn

bing_and_nrc <- bind_rows(
  pride_prejudice %>%
    inner_join(get_sentiments("bing")) %>%
    mutate(method = "Bing et al."),
  pride_prejudice %>%
    inner_join(get_sentiments("nrc") %>%
                 filter(sentiment %in% c(
                   "positive",
                   "negative"
                 ))) %>%
    mutate(method = "NRC")
) %>%
  count(method, index = linenumber %/% 80, sentiment) %>%
  pivot_wider(names_from = sentiment,
              values_from = n,
              values_fill = 0) %>%
  mutate(sentiment = positive - negative)

bind_rows(afinn,
          bing_and_nrc) %>%
  ggplot(aes(index, sentiment, fill = method)) +
  geom_col(show.legend = FALSE) +
  facet_wrap( ~ method, ncol = 1, scales = "free_y")


# Let’s look briefly at how many positive and negative words are in these lexicons
get_sentiments("nrc") |> 
  filter(sentiment %in% c("positive", "negative")) |>
  count(sentiment)

get_sentiments("bing") |> 
  count(sentiment)

# One advantage of having the data frame with both sentiment and word is that we can analyze word counts that contribute to each sentiment. By implementing count() here with arguments of both word and sentiment, we find out how much each word contributed to each sentiment.

bing_word_counts <- tidy_books |> 
  inner_join(get_sentiments("bing")) |> 
  count(word, sentiment, sort = TRUE) |> 
  ungroup()

bing_word_counts |> 
  group_by(sentiment) |> 
  slice_max(n, n=10) |> 
  ungroup() |>
  mutate(word = reorder(word, n)) |>
  ggplot(aes(n, word, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~sentiment, scales = "free_y") +
  labs(x = "Contribution to sentiment", y = NULL)

# If it were appropriate for our purposes, we could easily add “miss” to a custom stop-words list using bind_rows()
custom_stop_words <- bind_rows(tibble(word = c("miss"),lexicon = c("custom")), stop_words)

custom_stop_words



# Wordcloud
tidy_books |> 
  anti_join(stop_words) |> 
  count(word) |> 
  with(wordcloud(word, n, max.words = 100))

# In other functions, such as comparison.cloud(), you may need to turn the data frame into a matrix with reshape2’s acast(). Let’s do the sentiment analysis to tag positive and negative words using an inner join, then find the most common positive and negative words. Until the step where we need to send the data to comparison.cloud(), this can all be done with joins, piping, and dplyr because our data is in tidy format.

tidy_books |> 
  inner_join(get_sentiments("bing")) |> 
  count(word, sentiment, sort = TRUE) |> 
  acast(word ~ sentiment, value.var = "n", fill =0) |> 
  comparison.cloud(colors = c("gray20", "gray80"), max.words = 100)
  
# We may want to tokenize text into sentences, and it makes sense to use a new name for the output column in such a case.
p_and_p_sentences <- tibble(text=prideprejudice) |> 
  unnest_tokens(sentence, text, token = "sentences")
p_and_p_sentences

# Another option in unnest_tokens() is to split into tokens using a regex pattern. We could use this, for example, to split the text of Jane Austen’s novels into a data frame by chapter.
austen_chapters <- austen_books() |> 
  group_by(book) |> 
  unnest_tokens(chapter, text, token = "regex", pattern = "Chapter|CHAPTER [\\dIVXLC]") |>
  ungroup()

austen_chapters

austen_chapters |> 
  group_by(book) |>
  summarise(chapters = n())


# show whats in the gi dictionary
lsd <- data_dictionary_LSD2015 %>% as.list()


lsd

get_sentiments("loughran")


lsd <- data_dictionary_LSD2015 %>% as.list()
lsd_pos <- data.frame(lsd[2], sentiment = "positive")
names(lsd_pos)[1] <- "word"
lsd_neg <- data.frame(lsd[1], sentiment = "negative")
names(lsd_neg)[1] <- "word"
lsd <- rbind(lsd_pos, lsd_neg) # 4567 words
lsd$word <- gsub("[*]", "", lsd$word)
lsd$word <- lemmatize_strings(lsd$word)
lsd <- lsd %>% distinct() # 3911 words
lsd$dict <- "lsd"
lsd


get_sentiments("afinn")
get_sentiments("bing")
get_sentiments("nrc")
get_sentiments("loughran")



sample <- bind_rows(afinn, bing_nrc_loughran)
sample
bing_nrc_loughran




bing_and_nrc <- bind_rows(
  pride_prejudice %>% 
    inner_join(get_sentiments("bing")) %>%
    mutate(method = "Bing et al."),
  pride_prejudice %>% 
    inner_join(get_sentiments("nrc") %>% 
                 filter(sentiment %in% c("positive", 
                                         "negative"))
    ) %>%
    mutate(method = "NRC")) %>%
  count(method, index = linenumber %/% 80, sentiment) %>%
  pivot_wider(names_from = sentiment,
              values_from = n,
              values_fill = 0) %>% 
  mutate(sentiment = positive - negative)

for (i in c("nrc", "bing", "loughran")) {
  print(get_sentiments(i) |> 
    filter(sentiment %in% c("positive", "negative")) |>
    count(sentiment) |> 
    mutate(ratio = n / sum(n)))
}


# change origin_species to corpus
data_dictionary_LSD2015
txt <- "This aggressive policy will not win friends."
tokens_lookup(tokens(txt), dictionary = data_dictionary_LSD2015, exclusive = FALSE)


?tokens

library(corpustools)
library(httr)
library(readtext)
library(quanteda)
#get text from a url
url <- "https://www.gutenberg.org/cache/epub/35/pg35.txt"
text <- GET(url)
text <- content(text, as = "text")
text
sample <- readtext(url)
View(sample)
my.corpus <- corpus(text)
docvars(my.corpus, "Textno") <- sprintf("%02d", 1:ndoc(my.corpus))
my.corpus

my.corpus.stats <- summary(my.corpus)
my.corpus.stats$Text <- reorder(my.corpus.stats$Text, 1:ndoc(my.corpus), order = T)
my.corpus.stats



origin_species %>% 
  group_by(index = linenumber %/% 80)

#convert darwin_books to rdata file





