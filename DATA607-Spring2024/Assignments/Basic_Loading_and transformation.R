rm("dsin", "nba_raptor")
# delete values
rm(list = ls())

#Import data from github
urlfile <-
  'https://raw.githubusercontent.com/RDLong718/DATA607-Spring24/main/DATA607-Spring2024/Assignments/nba-raptor/latest_RAPTOR_by_player.csv'
latest_Raptor_by_player <- read.csv(url(urlfile))

# View the first 6 rows of the data
head(latest_Raptor_by_player)

# View dataset
View(latest_Raptor_by_player)

# Which player has the highest RAPTOR value?
highest_raptor <-
  latest_Raptor_by_player[which.max(latest_Raptor_by_player$mp), ]
highest_raptor

# using filter and pipes
highest_raptor <-
  latest_Raptor_by_player %>%
  filter(raptor_box_mp == max(raptor_box_mp))

# create data frame with only a few columns
nba_raptor <-
  latest_Raptor_by_player %>%
  select(player_name, raptor_offense, raptor_defense, raptor_total, mp)

# change mp column to minutes_played
nba_raptor <- nba_raptor %>% rename(minutes_played = mp)

# sort the data by raptor_offense using pipes
nba_raptor %>% 
  arrange(desc(raptor_offense)) %>%
  filter(minutes_played > 1000) %>%
  head(10)

# The relationship between the Raptor offense and defense scores is shown in the scatter plot below
ggplot(nba_raptor, aes(x = raptor_offense, y = raptor_defense)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Raptor Offense vs Defense",
       x = "Raptor Offense",
       y = "Raptor Defense")




