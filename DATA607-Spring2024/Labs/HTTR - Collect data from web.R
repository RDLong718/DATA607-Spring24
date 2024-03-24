# httr Request
library(httr)
r <- GET("http://httpbin.org/get", add_headers(Name = "Rashad"))
url <- "http://httpbin.org/post"
body <- list(a=1,b=2,c=3)
r <- POST(url, body = body, encode = "json")
# r <- POST(url, body = body, encode = "form")
# r <- POST(url, body = body, encode = "multipart")
# r <- POST(url, body = body, encode = "raw")

# jsonlite
library(jsonlite)
toJSON(list(a=1, b=2, c=3))
fromJSON('{"a":1,"b":2,"c":3}')

r <- GET("http://httpbin.org/get")
r
r$status_code
http_status(r)

# Error Handling
r2 <- r
r2$status_code <- 404
warn_for_status(r2)
stop_for_status(r2)

# Headers
headers(r)
headers(r)$`server`

# Content
r$content
content(r, "raw")
content(r, "text")
content(r, "parse")

# Request Frozen from OMDapi
url <- "http://www.omdbapi.com/?t=Frozen&apikey=1c7be7bb"
frozen <- GET(url)
frozen

details <- content(frozen, "parsed")
details
details$Title
details$Year
details$Plot

# Web Scraping
library(rvest)

# 1. Download the HTML and Turn it into an XML file with read_html()
frozen <- read_html("https://www.imdb.com/title/tt2294629/?ref_=fn_al_tt_2")


#2. Extract specific nodes with html_nodes()
cast <- html_nodes(frozen, "a.sc-bfec09a1-1")
cast

#3.  Extract content from nodes with html_text(), html_name(), html_attrs(), html_children(), html_tables()

html_text(cast)
cast
html_name(cast)
html_attrs(cast)
html_children(cast)



midwood <- read_html("https://www.bestplaces.net/economy/zip-code/new_york/new_york/11230")
midwood

tables <- html_nodes(midwood, css = "table")
tables
html_table(tables, header=TRUE)[[1]]

# selectorGaget
cast2 <- html_nodes(frozen, ".gCQkeh")
html_text(cast2)

getAnywhere(html)

























