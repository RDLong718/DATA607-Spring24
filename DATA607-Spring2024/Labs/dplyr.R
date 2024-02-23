# dplyr.R
# source: http://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html
# next generation of plyr - Hadley Wickham's implementation of "grammar of data manipulation"
# where ggplot2 implemented "grammar of graphics"
# * plyr primarily designed to provide more consistent api over same surface area as apply() family, etc.
# * dplyr focuses primarily on data frames
#   (and other rectangular objects like PostgreSQL, MySQL and sqlite resultsets, and data.table objects)
# * support mostly removed for lists, etc.
# * dplyr much faster than plyr

head(mtcars)
# task: show average mpg and average weight based on # of cylinders and whether
# there is automatic transmission; show only for cars that get more than 20 mpg
# sample output:
# cyl am   avgmpg   avgwt
# 1   4  0 22.90000 2.93500
# 2   4  1 28.07500 2.04225
# 3   6  1 20.56667 2.75500

# install.packages("dplyr")

# "A data only package containing commercial domestic flights
# that departed Houston (IAH and HOU) in 2011."
library(hflights)

# dplyr is a faster subset of dataframe commands from the flyer package that also
# implements "chaining of verbs"
library(dplyr)

vignette(package="dplyr")
vignette("introduction", package="dplyr")

# command to show the datasets that come with a specific package
(data(package="dplyr")$results)

dim(hflights)
head(hflights)

# tbl_df: wrapper function for convenience
hflights_df <- tibble::as_tibble(hflights)
hflights_df

# plyr has 5 basic data manipulation verbs
# Hadley Wickham's philosophy is that by having less functions
# (i.e. constraining the surface area of the API), data analysts
# become more productive!

# filter(), arrange(), select(), mutate(), summarise()
# filter - keep rows matching criteria
# arrange - reorder rows
# select - pick columns by name
# mutate - add new variables
# summarise - reduce variables to values

# parantheses around statement is equivalent to print command
(filter(hflights_df, Month == 9, DayofMonth == 18))

# equivalent statements using "base R"
(hflights[hflights$Month == 9 & hflights$DayOfMonth == 18,])
# can also use base R subset() command

(filter(hflights_df, Month==1 | Month ==2))

# arrange() - like filter, but reorders rows instead of filtering them
arrange(hflights_df, DayofMonth, Month, Year)
arrange(hflights_df, desc(ActualElapsedTime))

# see also plyr::arrange()
# dplyr()::arrange is implemented as a wrapper around base::order()
(hflights[order(hflights$DayofMonth, hflights$Month, hflights$Year),])
(hflights[order(desc(hflights$ActualElapsedTime)),])

# select() -- selects columns - similiar to select argument in base::subset()
select(hflights_df, Year, Month, DayOfWeek, ArrDelay)
select(hflights_df, Year:DayOfWeek)
select(hflights_df, -(Year:DayOfWeek))

# mutate() - add columns
# cf plyr::mutate(), base::transform()
mutate(hflights_df, 
       gain = ArrDelay - DepDelay,
       speed = Distance/ AirTime * 60)

# unlike transform(), mutate() lets you use columns you just created:
mutate(hflights_df,
       gain= ArrDelay - DepDelay,
       gain_per_hour = gain / (AirTime / 60) )

# following transform() generates an error
transform(hflights,
          gain= ArrDelay - DepDelay,
          gain_per_hour = gain / (AirTime / 60))

## Grouped Operations
(planes <- group_by(hflights_df, TailNum))
delay <- summarise(planes,
                   count=n(),
                   dist=mean(Distance, na.rm = TRUE),
                   delay=mean(ArrDelay, na.rm = TRUE))
delay
delay <- filter(delay, count > 20, dist < 2000)
delay

# aggregate functions that you can use with summarise:
# base R:  min(), max(), mean(), sum(), sd(), median(), IQR()  
# dplyr: n(): number of observations in current group
#        n_distinct()
#        first(), last, nth(x,n) - like x[1], x[length(x)] and x[n]
# functions you write yourself!

# Find number of planes and number of flights that go to each possible destination
(destinations <- group_by(hflights_df, Dest))
summarise(destinations,
          planes= n_distinct(TailNum),
          flights=n())

# grouping by multiple variables - progressively rolls up a dataset
# careful about types of numbers you roll-up; eg. avoid means, variance, ytd totals, etc.
daily <- group_by(hflights_df, Year, Month, DayofMonth)
(per_day <- summarise(daily, flights=n()))
(per_month <- summarise(per_day, flights=sum(flights)))
(per_year <- summarise(per_month, flights=sum(flights)))

# chaining

# method 1: save intermediate results:  I like to start here!!
a1 <- group_by(hflights, Year, Month, DayofMonth)
a2 <- select(a1, Year:DayofMonth, ArrDelay, DepDelay)
a3 <- summarise(a2, 
                arr = mean(ArrDelay, na.rm=TRUE),
                dep = mean(DepDelay, na.rm = TRUE))
a4 <- filter(a3, arr > 30 | dep > 30)

# or wrap function calls inside each other

filter(
  summarise(
    select(
      group_by(hflights, Year, Month, DayofMonth),
      Year:DayofMonth, ArrDelay, DepDelay),
    arr = mean(ArrDelay, na.rm = TRUE),
    dep = mean(DepDelay, na.rm = TRUE)
    ),
  arr > 30 | dep > 30
)

# benchmark -  R coders often compare plyr, dplyr, base functions, and data.table()
# "plyr - 13 hour job -> < 1 minute in dplyr (or data.table())"
system.time(filter(
  summarise(
    select(
      group_by(hflights, Year, Month, DayofMonth),
      Year:DayofMonth, ArrDelay, DepDelay),
    arr = mean(ArrDelay, na.rm = TRUE),
    dep = mean(DepDelay, na.rm = TRUE)
  ),
  arr > 30 | dep > 30
))


# %>% operator f(y) turns into f(x,y) - lets you read from left-to-right, top-to-bottom,
# vs. inside-out as above
# see also: http://www.r-statistics.com/2014/08/simpler-r-coding-with-pipes-the-present-and-future-of-the-magrittr-package/
  

hflights %>%
  group_by(Year, Month, DayofMonth) %>%
  select(Year:DayofMonth, ArrDelay, DepDelay) %>%
  summarise(
    arr = mean(ArrDelay, na.rm = TRUE),
    dep = mean(DepDelay, na.rm = TRUE)
  ) %>%
  filter(arr > 30 | dep > 30)
