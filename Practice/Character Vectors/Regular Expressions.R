library(tidyverse)
library(gapminder)
countries <- levels(gapminder$country)
str_detect(fruit, pattern = "fruit")

my_fruit <- str_subset(fruit, pattern = "fruit")
my_fruit
str_split(my_fruit, pattern = " ")
# If you are willing to commit to the number of pieces, you can use str_split_fixed() and get a character matrix. You’re welcome!
str_split_fixed(my_fruit, pattern = " ", n=2)
# If you want to split the string into a data frame, you can use separate() from tidyr.
my_fruit_df <-  tibble(my_fruit)
my_fruit_df |> separate(my_fruit, into = c("pre", "post"), sep = " ")
# Count characters in your strings with str_length(). Note this is different from the length of the character vector itself.
length(my_fruit)
str_length(my_fruit)

# You can snip out substrings based on character position with str_sub()
head(fruit) |>
  str_sub(1,3)

# The start and end arguments are vectorised. Example: a sliding 3-character window.
tibble(fruit) |> 
   head() |>  
   mutate(snip = str_sub(fruit,1:6,3:8))
# Finally, str_sub() also works for assignment, i.e. on the left hand side of <-.
x <- head(fruit,3)
x
str_sub(x, 1, 3) <- "XXX"  
x  
# You can collapse a character vector of length n > 1 to a single string with str_c(), which also has other uses
head(fruit) |> 
  str_c(collapse = ", ")
  
# If you have two or more character vectors of the same length, you can glue them together element-wise, to get a new vector of that length. Here are some … awful smoothie flavors?
str_c(fruit[1:4], fruit[5:8], sep = " & ")

# Element-wise catenation can be combined with collapsing
str_c(fruit[1:4],fruit[5:8], sep = " & ", collapse = ", ")


# If the to-be-combined vectors are variables in a data frame, you can use tidyr::unite() to make a single new variable from them.

fruit_df <- tibble(
  fruit1 = fruit[1:4],
  fruit2 = fruit[5:8]
)
fruit_df |> 
  unite("flavor_combo", fruit1, fruit2, sep = " & ")

# You can replace a pattern with str_replace(). Here we use an explicit string-to-replace, but later we revisit with a regular expression

str_replace(my_fruit, pattern = "fruit", replacement = "THINGY")

#A special case that comes up a lot is replacing NA, for which there is str_replace_na()
melons <- str_subset(fruit, pattern = "melon")
melons[2] <- NA
melons
str_replace_na(melons, "UNKOWN MELON")

# If the NA-afflicted variable lives in a data frame, you can use tidyr::replace_na()
tibble(melons) |> 
  replace_na(replace = list(melons = "UNKOWN MELON"))

# The first metacharacter is the period ., which stands for any single character, except a newline (which by the way, is represented by \n).
str_subset(countries, pattern = "i.a")

# Note how the regex i.a$ matches many fewer countries than i.a alone. Likewise, more elements of my_fruit match d than ^d, which requires “d” at string start.
str_subset(countries, pattern = "i.a$")
countries
str_subset(my_fruit, pattern = "d")
str_subset(my_fruit, pattern = "^d")

# The metacharacter \b indicates a word boundary and \B indicates NOT a word boundary. This is our first encounter with something called “escaping” and right now I just want you at accept that we need to prepend a second backslash to use these sequences in regexes in R. We’ll come back to this tedious point later.
str_subset(fruit, pattern="melon")
str_subset(fruit,pattern = "\\bmelon")
str_subset(fruit,pattern = "\\Bmelon")

# Here we match ia at the end of the country name, preceded by one of the characters in the class. Or, in the negated class, preceded by anything but one of those characters.
str_subset(countries, pattern = "[nls]ia$")
str_subset(countries, pattern = "[^nls]ia$")

# Here we revisit splitting my_fruit with two more general ways to match whitespace: the \s metacharacter and the POSIX class [:space:]. Notice that we must prepend an extra backslash \ to escape \s and the POSIX class has to be surrounded by two sets of square brackets.
str_split_fixed(fruit, pattern = " ", n = 2)
str_split_fixed(my_fruit, pattern = "\\s", n = 2)
str_split_fixed(my_fruit, pattern = "[[:space:]]", n = 2)

# Let’s see the country names that contain punctuation.
str_subset(countries, pattern = "[[:punct:]]")

# l.*e will match strings with 0 or more characters in between, i.e. any string with an l eventually followed by an e. This is the most inclusive regex for this example, so we store the result as matches to use as a baseline for comparison.
matches <- str_subset(fruit, pattern = "l.*e")
matches

# Change the quantifier from * to + to require at least one intervening character. The strings that no longer match: all have a literal le with no preceding l and no following e.
list(match = intersect(matches, str_subset(fruit, pattern = "l.+e")),no_match = setdiff(matches, str_subset(fruit, pattern = "l.+e")))

# Change the quantifier from * to ? to require at most one intervening character. In the strings that no longer match, the shortest gap between l and following e is at least two characters.
list(match = intersect(matches, str_subset(fruit, pattern = "l.?e")),
     no_match = setdiff(matches, str_subset(fruit, pattern = "l.?e")))

# Finally, we remove the quantifier and allow for no intervening characters. The strings that no longer match lack a literal le
list(match = intersect(matches, str_subset(fruit, pattern = "le")),
     no_match = setdiff(matches, str_subset(fruit, pattern = "le")))

# Here is routine, non-regex use of backslash \ escapes in plain vanilla R strings. We intentionally use cat() instead of print() here.
cat("Do you use \"airquotes\" much?")

# To insert newline (\n) or tab (\t):
cat("before the newline\nafter the newline")
cat("before the tab\tafter the tab")

## cheating using a POSIX class ;)
str_subset(countries, pattern = "[[:punct:]]")
## using two backslashes to escape the period
str_subset(countries, pattern = "\\.")

# A last example that matches an actual square bracket.
x <- c("whatever","X is distirbuted U[0,1]")
x
str_subset(x, pattern = "\\[")













