library(psych)

# Read in csv from github repo
my_flights <- read.csv("https://raw.githubusercontent.com/RDLong718/DATA607-Spring24/main/DATA607-Spring2024/Assignments/Assignment%20Tidying%20and%20Transforming%20Data/tidy_flights.csv")

# Remove All variables
rm(list=ls())

# Make data long structure using pivot_longer using piping

my_flights_long <- my_flights %>%
  pivot_longer(cols = -c(airline, destination), names_to = "month", values_to = "arr_delay")

my_flights
#change column names

# replace blanks with null values in airline column using piping
my_flights <- my_flights %>%
  mutate(Airline = ifelse(Airline == "", NA, Airline))
my_flights$Airline[my_flights$Airline == ""] <- NA
my_flights

my_flights |> fill(Airline)

#Which airline had the most count where arrival = delayed
my_flights |> 
  filter(Arrival =="delayed") |> 
  group_by(Airline) |>
  summarise(Flights = sum(Count)) |> 
  arrange(desc(Flights)) |> 
  ggplot(aes(x = ))
  
# bar plot it
my_flights |> 
  filter(Arrival =="delayed") |> 
  group_by(Airline) |>
  summarise(Flights = sum(Count)) |> 
  arrange(desc(Flights)) |> 
  ggplot(aes(x = Airline, y = Flights)) +
  geom_bar(stat = "identity", fill = "red") +
  labs(title = "Delayed Flights by Airline", x = "Airline", y = "Number of Flights") +
  geom_text(aes(label = Flights), vjust = -.3)

# Which destination had the most delays
my_flights |> 
  filter(Arrival =="delayed" , Airline == "ALASKA") |> 
  group_by(Destination) |>
  summarise(Flights = sum(Count)) |> 
  arrange(desc(Flights)) |>
  ggplot(aes(x = reorder(Destination,-Flights), y = Flights)) +
  geom_bar(stat = "identity", fill = "blue") +
  labs(title = "Delayed Flights by Destination for AM WEST", x = "Destination", y = "Number of Flights") +
  geom_text(aes(label = Flights), vjust = -.3)

# What is the sum of total flights to each destination for AM west?
my_flights |>
  filter(Airline == "AM WEST") |>
  group_by(Destination) |>
  summarise(Flights = sum(Count)) |>
  arrange(desc(Flights)) |>
  ggplot(aes(x = reorder(Destination, -Flights), y = Flights)) +
  geom_bar(stat = "identity", fill = "green") +
  labs(title = "Total Flights by Destination", x = "Destination", y = "Number of Flights") +
  geom_text(aes(label = Flights), vjust = -.3)

# Summary of Descriptive statistics for the delayed flights grouped by Airline

delayed_flights <- my_flights |> 
  filter(Arrival =="delayed")

delayed_flights_summary <- describeBy(delayed_flights$Count,group=delayed_flights$Airline,mat=TRUE)

delayed_flights_summary

View(delayed_flights_summary)

#remove first column
delayed_flights_summary <- delayed_flights_summary[,-1]
delayed_flights_summary
colnames(delayed_flights_summary)[1] <- "Airline"
delayed_flights_summary

as_tibble(delayed_flights_summary)




















