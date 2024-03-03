
library(untidydata)
library(tidyverse)

install.packages("devtools")
devtools::install_github("jvcasillas/untidydata", force=TRUE)


data(language_diversity)
View(language_diversity)


# view structure of language_diversity dataframe
str(language_diversity)

# view first few rows of language_diversity dataframe
head(language_diversity)

# Find the unique values of the 'Measurement' column
unique(language_diversity$Measurement)

wide_languages <- language_diversity |> 
  pivot_wider(names_from = Measurement, values_from = Value)

str(wide_languages)

# Change names of specific columns
wide_languages <- wide_languages |>
  rename(
    "Languages" = "Langs",
    "Weather Stations" = "Stations",
    "Mean Growth" = "MGS",
    "Growth Deviation" = "Std"
  )

str(wide_languages)
  
# Does the area size of the country affect language diversity?
wide_languages |>
  ggplot(aes(x = Area, y = Languages)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Language Diversity vs. Country Area",
       x = "Country Area (sq. km)",
       y = "Number of Languages") +
  theme_minimal()
data(spanish_vowels)

# Remove language diversity
rm(language_diversity)
