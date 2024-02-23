# Download the dataset
majors_url <- "https://raw.githubusercontent.com/fivethirtyeight/data/master/college-majors/majors-list.csv"
majors <- read.csv(majors_url)

# provide code that identifies the majors that contain either "DATA" or "STATISTICS"
grep(pattern = "DATA|STATISTICS", majors$Major, value = TRUE, ignore.case = TRUE)
?grep

#2 Write code that transforms the data below:
# [1] "bell pepper"  "bilberry"     "blackberry"   "blood orange"
# [5] "blueberry"    "cantaloupe"   "chili pepper" "cloudberry"  
# [9] "elderberry"   "lime"         "lychee"       "mulberry"    
# [13] "olive"        "salal berry"
# Into a format like this:
#   c("bell pepper", "bilberry", "blackberry", "blood orange", "blueberry", "cantaloupe", "chili pepper", "cloudberry", "elderberry", "lime", "lychee", "mulberry", "olive", "salal berry")
paste(c("bell pepper", "bilberry", "blackberry", "blood orange", "blueberry", "cantaloupe", "chili pepper", "cloudberry", "elderberry", "lime", "lychee", "mulberry", "olive", "salal berry"), collapse = ", ")

foods_formatted

x <- ' [1] "bell pepper" "bilberry" "blackberry" "blood orange" [5] "blueberry" "cantaloupe" "chili pepper" "cloudberry" [9] "elderberry" "lime" "lychee" "mulberry" [13] "olive" "salal berry" '

#Use regex to build list

             
             
             
             
             
             
             
             
        