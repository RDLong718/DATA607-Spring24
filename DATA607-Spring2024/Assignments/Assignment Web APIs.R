
# First we want to get the book list names from the New York Times API
list_names <- "https://api.nytimes.com/svc/books/v3/lists/names.json?api-key=DmmA4yncJS7ykyBcQGGtM5KxP4AYnaWa"

list_names <- fromJSON(list_names)
list_names
list_names <- list_names$results

glimpse(list_names)


# Now we want to get the best sellers from a particular category the New York Times API

science_best_sellers <- "https://api.nytimes.com/svc/books/v3/lists/current/science.json?api-key=DmmA4yncJS7ykyBcQGGtM5KxP4AYnaWa"

science_best_sellers <- fromJSON(science_best_sellers)
maybe_clean <- science_best_sellers$results
maybe_clean <- maybe_clean$books

category_names$results
