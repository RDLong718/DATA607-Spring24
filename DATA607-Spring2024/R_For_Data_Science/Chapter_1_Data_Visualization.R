# Chapter 1 of R for Data Science
penguins

# alternative view, where you can see all variables and the first few observations of each variable
glimpse(penguins)
View(penguins)

# To learn more about penguins
?penguins

# Our ultimate goal in this chapter is to recreate the following visualization displaying the relationship between flipper lengths and body masses of these penguins, taking into consideration the species of the penguin.
ggplot(data=penguins,
       mapping = aes(x = flipper_length_mm, y = body_mass_g)) + geom_point(mapping = aes(color=species, shape = species))+ geom_smooth(method = "lm") + labs( title = "Body mass and flipper length", subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo penguins", x = "Flipper length (mm)", y = "Body mass (g)", color = "Species", shape = "Species") + scale_color_colorblind()

# How many rows are in penguins? How many columns?