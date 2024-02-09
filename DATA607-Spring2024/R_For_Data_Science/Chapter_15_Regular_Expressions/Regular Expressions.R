library(babynames)
library(stringr)
library(ggplot2)

vowels <- c("a", "e", "i", "o", "u")
consanants <- c("b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z")


# The simplest patterns consist of letters and numbers which match those characters exaxctly:
str_view(fruit,"berry")

# For example, . will match any character3, so "a." will match any string that contains an “a” followed by another character :
str_view(c("a", "ab", "ae", "bd", "ea", "eab"), "a.")

# Or we could find all the fruits that contain an “a”, followed by three letters, followed by an “e”:
str_view(fruit, "a...e")

# Quantifiers control how many times a pattern can match:
# ? makes a pattern optional (i.e. it matches 0 or 1 times)
# + lets a pattern repeat (i.e. it matches at least once)
# * lets a pattern be optional or repeat (i.e. it matches any number of times, including 0).
str_view(c("a", "ab", "abb"), "ab?")
str_view(c("a", "ab", "abb"), "ab+")
str_view(c("a", "ab", "abb"), "ab*")

# Character classes are defined by [] and let you match a set of characters, e.g., [abcd] matches “a”, “b”, “c”, or “d”. You can also invert the match by starting with ^: [^abcd] matches anything except “a”, “b”, “c”, or “d”. We can use this idea to find the words containing an “x” surrounded by vowels, or a “y” surrounded by consonants:
str_view(words,"[aeiou]x[aeiou]")
str_view(words,"[^aeiou]y[^aeiou]")

# You can use alternation, |, to pick between one or more alternative patterns. For example, the following patterns look for fruits containing “apple”, “melon”, or “nut”, or a repeated vowel.
str_view(fruit, "apple|melon|nut")
str_view(fruit, "aa|ee|ii|oo|uu")

# str_detect() returns a logical vector that is TRUE if the pattern matches an element of the character vector and FALSE otherwise:
str_detect(c("a", "b","c"), "[aeiou]")

# Since str_detect() returns a logical vector of the same length as the initial vector, it pairs well with filter(). For example, this code finds all the most popular names containing a lower-case “x”:
babynames |> 
  filter(str_detect(name, "x")) |> 
  count(name,wt=n, sort =TRUE)
View(babynames)
?count

# We can also use str_detect() with summarize() by pairing it with sum() or mean(): sum(str_detect(x, pattern)) tells you the number of observations that match and mean(str_detect(x, pattern)) tells you the proportion that match. For example, the following snippet computes and visualizes the proportion of baby names4 that contain “x”, broken down by year. It looks like they’ve radically increased in popularity lately!
babynames |> 
  group_by(year) |> 
  summarize(prop_x = mean(str_detect(name, "x"))) |> 
  ggplot(aes(x = year, y = prop_x)) +
  geom_line()

# The next step up in complexity from str_detect() is str_count(): rather than a true or false, it tells you how many matches there are in each string.
x <- c("apple", "banana", "pear", "orange", "grape")
str_count(x, "p")

# Note that each match starts at the end of the previous match, i.e. regex matches never overlap. For example, in "abababa", how many times will the pattern "aba" match? Regular expressions say two, not three:
str_count("abababa", "aba")
str_view("abababa", "aba")

# It’s natural to use str_count() with mutate(). The following example uses str_count() with character classes to count the number of vowels and consonants in each name.

babynames |> 
  count(name) |> 
  mutate( vowels = str_count(name, regex("[aeiou]", ignore_case= TRUE)),
          consonants = str_count(name, regex("[^aeiou]", ignore_case= TRUE)),
          name = str_to_lower(name))

# As well as detecting and counting matches, we can also modify them with str_replace() and str_replace_all(). str_replace() replaces the first match, and as the name suggests, str_replace_all() replaces all matches.
x <- c("apple", "banana", "pear", "orange", "grape")
str_replace_all(x, "[aeiou]", "-")

# str_remove() and str_remove_all() are handy shortcuts for str_replace(x, pattern, ""):
x <- c("apple", "banana", "pear", "orange", "grape")
str_remove_all(x, "[aeiou]")
str_remove(x, "[aeiou]")

# The last function we’ll discuss uses regular expressions to extract data out of one column into one or more new columns: separate_wider_regex(). It’s a peer of the separate_wider_position() and separate_wider_delim() functions that you learned about in Section 14.4.2. These functions live in tidyr because they operate on (columns of) data frames, rather than individual vectors.

# Let’s create a simple dataset to show how it works. Here we have some data derived from babynames where we have the name, gender, and age of a bunch of people in a rather weird format5:

df <- tribble(
  ~str,
  "<Sheryl>-F_34",
  "<Kisha>-F_45", 
  "<Brandon>-N_33",
  "<Sharon>-F_38", 
  "<Penny>-F_58",
  "<Justin>-M_41", 
  "<Patricia>-F_84", 
) 

# To extract this data using separate_wider_regex() we just need to construct a sequence of regular expressions that match each piece. If we want the contents of that piece to appear in the output, we give it a name:
df |> 
  separate_wider_regex(
    str,
    patterns = c(
      "<", 
      name = "[A-Za-z]+", 
      ">-", 
      gender = ".",
      "_",
      age = "[0-9]+"
    )
  )

# What baby name has the most vowels? What name has the highest proportion of vowels? (Hint: what is the denominator?)
babynames |> 
  count(name) |> 
  mutate(vowels = str_count(name, "[aeiou]")) |> 
  arrange(desc(vowels)) |> 
  head(10)

# What name has the highest proportion of vowels?
babynames |> 
  count(name) |> 
  mutate(vowels = str_count(name, "[aeiou]"), 
         consonants = str_count(name, "[^aeiou]"), 
         prop_vowels = vowels / (vowels + consonants)) |> 
  arrange(desc(prop_vowels)) |> 
  head(10)

# Replace all forward slashes in "a/b/c/d/e" with backslashes. What happens if you attempt to undo the transformation by replacing all backslashes with forward slashes?
str_replace_all("a/b/c/d/e", "/", "\\")

# Implement a simple version of str_to_lower() using str_replace_all()
str_to_lower <- function(string) {
  str_replace_all(string, "A", "a") |> 
  str_replace_all("B", "b") |> 
  str_replace_all("C", "c") |> 
  str_replace_all("D", "d") |> 
  str_replace_all("E", "e") |> 
  str_replace_all("F", "f") |> 
  str_replace_all("G", "g") |> 
  str_replace_all("H", "h") |> 
  str_replace_all("I", "i") |> 
  str_replace_all("J", "j") |> 
  str_replace_all("K", "k") |> 
  str_replace_all("L", "l") |> 
  str_replace_all("M", "m") |> 
  str_replace_all("N", "n") |> 
  str_replace_all("O", "o") |> 
  str_replace_all("P", "p") |> 
  str_replace_all("Q", "q") |> 
  str_replace_all("R", "r") |> 
  str_replace_all("S", "s") |> 
  str_replace_all("T", "t") |> 
  str_replace_all("U", "u") |> 
  str_replace_all("V", "v") |> 
  str_replace_all("W", "w") |> 
  str_replace_all("X", "x") |> 
  str_replace_all("Y", "y") |> 
  str_replace_all("Z", "z")
}

# Create a regular expression that will match telephone numbers as commonly written in your country.

# ^\(?([2-9]\d{2})\)?[-.]?([2-9]\d{2})[-.]?(\d{4})$
  

# In order to match a literal ., you need an escape which tells the regular expression to match metacharacters6 literally. Like strings, regexps use the backslash for escaping. So, to match a ., you need the regexp \.. Unfortunately this creates a problem. We use strings to represent regular expressions, and \ is also used as an escape symbol in strings. So to create the regular expression \. we need the string "\\.", as the following example shows.
dot <- "\\."
str_view(dot)
str_view(c("abc","a.c","bef"),"a\\.c")

# If \ is used as an escape character in regular expressions, how do you match a literal \? Well, you need to escape it, creating the regular expression \\. To create that regular expression, you need to use a string, which also needs to escape \. That means to match a literal \ you need to write "\\\\" — you need four backslashes to match one!
x <- "a\\b"
str_view(x)
str_view(x,"\\\\")

# Alternatively, you might find it easier to use the raw strings you learned about in Section 14.2.2). That lets you avoid one layer of escaping:
str_view(x, r"{\\}")

# If you’re trying to match a literal ., $, |, *, +, ?, {, }, (, ), there’s an alternative to using a backslash escape: you can use a character class: [.], [$], [|], ... all match the literal values.
str_view(c("a.b","a$b","a|b"),"[|]")
str_view(c("a.b","a$b","a|b"),"[.]")

# By default, regular expressions will match any part of a string. If you want to match at the start or end you need to anchor the regular expression using ^ to match the start or $ to match the end:
str_view(fruit, "^a")
str_view(fruit, "e$")
str_view(fruit, "a$")


# To force a regular expression to match only the full string, anchor it with both ^ and $
str_view(fruit, "^apple$")
str_view(fruit, "apple")

# You can also match the boundary between words (i.e. the start or end of a word) with \b. This can be particularly useful when using RStudio’s find and replace tool. For example, if to find all uses of sum(), you can search for \bsum\b to avoid matching summarize, summary, rowsum and so on:
x <- c("summary(x)", "summarize(df)","rowsum(x)", "sum(x)")
str_view(x,"sum")
str_view(x,"\\bsum\\b")

# When used alone, anchors will produce a zero-width match:
str_view("abc", c("$", "^","\\b"))


# This helps you understand what happens when you replace a standalone anchor:
str_replace_all("abc",c("$","^","\\b"),"--")

# - defines a range, e.g., [a-z] matches any lower case letter and [0-9] matches any number.
# \ escapes special characters, so [\^\-\]] matches ^, -, or ].
x <- "abcd ABCD 12345 -!@#%."
str_view(x, "[abc]+")
str_view(x, "[a-z]+")
str_view(x, "[0-9]+")
str_view(x,"[^a-z0-9]+")
str_view("a-b-c", "[a-c]")
str_view("a-b-c","[a\\-c]")

# \d matches any digit;
# \D matches anything that isn’t a digit.
# \s matches any whitespace (e.g., space, tab, newline);
# \S matches anything that isn’t whitespace.
# \w matches any “word” character, i.e. letters and numbers;
# \W matches any “non-word” character

x <- "abcd ABCD 12345 -!@#%."
str_view(x, "\\d+")
str_view(x, "\\D+")
str_view(x, "\\s+")
str_view(x, "\\S+")
str_view(x, "\\w+")
str_view(x, "\\W+")

# The first way to use a capturing group is to refer back to it within a match with back reference: \1 refers to the match contained in the first parenthesis, \2 in the second parenthesis, and so on. For example, the following pattern finds all fruits that have a repeated pair of letters:
str_view(fruit, "(..)\\1")

# And this one finds all words that start and end with the same pair of letters:
str_view(words, "^(..).*\\1$")
str_view(words, "^(.).*\\1$")

str_view(words, "(..).*\\1")

# You can also use back references in str_replace(). For example, this code switches the order of the second and third words in sentences:
sentences |> 
  str_replace("(\\w+) (\\w+) (\\w+)","\\1 \\3 \\2") |> 
                str_view()
# If you want to extract the matches for each group you can use str_match(). But str_match() returns a matrix, so it’s not particularly easy to work with8:
sentences |> 
  str_match("the (\\w+) (\\w+)") |>
  head()

# You could convert to a tibble and name the columns:
sentences |> 
  str_match("the (\\w+) (\\w+)") |> 
  as_tibble(.name_repair = "minimal") |> 
  set_names(c("match", "word1", "word2"))

# Occasionally, you’ll want to use parentheses without creating matching groups. You can create a non-capturing group with (?:)
x <- c("a gray cat", "a grey dog")
str_match(x, "gr(e|a)y")  
str_match(x, "gr(?:e|a)y")  

# How would you match the literal string "'\?
str_view(c("a", "a'", "a'", "a'''", "Rashad"), "'\\'")

# Explain why each of these patterns don’t match a \: "\", "\\", "\\\".

# Given the corpus of common words in stingr::word, create regular expressions to match words that:
# a. Start with "y"
str_view(words, "^y")
# b. Don't start with "y"
str_view(words, "^[^y]")
# c. End with "x"
str_view(words, "x$")
# d. Are exactly three letters long
str_view(words, "^\\w{3}$")
str_view(words, "^...$")
# e. Have seven letters or more
str_view(words, "^\\w{7,}$")
str_view(words, "^.......+$")
# f. Contain a vowel-consonant pair
str_view(words, "[aeiou][^aeiou]")
# g. Contain at least two vowel-consonant pairs in a row.
str_view(words, "[aeiou][^aeiou][aeiou][^aeiou]")
# h. Only consist of repeated vowel-consonant pairs
str_view(words, "^(?:(?i)[aeiou][^aeiou]){2,}$")

# Create 11 regular expressions that match the British or American spellings for each of the following words: 
british_american <- c("airplane", "aeroplane", "aluminum", "aluminium","analog", "analogue","ass","arse","center","centre","defense","defence","donut","doughnut", "gray","grey", "modeling","modelling","skeptic","sceptic", "summarize","summarise")
# airplane/aeroplane
str_view(british_american, "a(?:ir|ero)plane")
#aluminum/aluminium
str_view(british_american, "alumin(?:um|ium)")
# analog/analogue
str_view(british_american, "analog(?:ue)?")  
# ass/arse
str_view(british_american, "a(?:ss|rse)")  
# center/centre
str_view(british_american,"cent(?:er|re)")
# defense/defence
str_view(british_american,"defen(?:se|ce)")
# donut/doughnut
str_view(british_american, "do(?:ugh|)nut")
# gray/grey
str_view(british_american,"gr(?:a|e)y")
# modeling/modelling
str_view(british_american,"model(?:l|)ing")
# skeptic/sceptic
str_view(british_american, "s(?:k|c)eptic")
# summarize/summarise
str_view(british_american,"summari(?:se|ze)")

# Switch the first and last letters in words. Which of those strings are still words?
words |>
  str_replace("([a-zA-Z])(.*)([a-zA-Z])","\\3\\2\\1") |>
  head(25)

# Describe, in words, what these expressions will match:
# (.)\1\1
str_view(words,"(.)\1\1")
# "(.)(.)\\2\\1"
str_view(words,"(.)(.)\\2\\1")
# (..)\1
str_view(words,"(..)\1")
# "(.).\\1.\\1"
str_view(words,"(.).\\1.\\1")
# "(.)(.)(.).*\\3\\2\\1"
str_view(words,"(.)(.)(.).*\\3\\2\\1")
sample_words <- c("aaa","bbb","xyz","bba", "cctv","brrr")
str_view(sample_words, "(.)\\1\\1")
































