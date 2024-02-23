# You can create strings with either single quotes or double quotes. Unlike other languages, there is no difference in behaviour. I recommend always using ", unless you want to create a string that contains multiple ".
string1 <- "This is a string"
string2 <- 'If I want to include a "quote" inside a string, I use single quotes'

# To include a literal single or double quote in a string you can use \ to “escape” it:
double_quote <- "\""
single_quote <- '\''
string1
string2
double_quote
single_quote

# The simplest patterns match exact strings:
x <- c("apple","banana","pear")
str_view(x,"an")

#The next step up in complexity is ., which matches any character (except a newline):
str_view(x,".a.")

# # To create the regular expression, we need \\
dot <- "\\."
writeLines(dot)

# And this tells R to look for an explicit 
str_view(c("abc","a.c","bef"), "a\\.c")

x <- "a\\b"
writeLines(x)
str_view(x, "\\\\")















