# Imports
library(tidyverse)
library(dplyr)
library(ggplot2)
library(sf)

list.files("./Data")

# **************************************************************#
# Top-Left - Collision frequency/severity at time of day
# **************************************************************#
# Tests to do:
# - percentage of collisions instead of no.
# - better colours

time_frequencies <- read_csv("./Data/collisions_by_time.csv")

# Bar version
time_frequency_plot <- ggplot(time_frequencies, aes(x = factor(time), y = count, fill = accident_severity)) +
  geom_bar(stat = "identity", position = "dodge", width=0.8) +
  coord_polar(theta = "x") +
  scale_fill_manual(values = c("Fatal" = "red", "Non-Fatal" = "green")) +
  labs(title = "Circular Time Plot of Accident Severity",
       x = "Time",
       y = "No. Collisions") + 
  theme_minimal()

ggsave("./Visualisations/time using bars.png", plot=time_frequency_plot, width = 10, height = 8)


# Line version
time_frequency_line_plot <- ggplot(time_frequencies, aes(x = time, y = count, group = accident_severity, color = accident_severity)) +
  geom_line()  +
  coord_polar() +
  theme_minimal()

ggsave("./Visualisations/time using lines.png", plot=time_frequency_line_plot, width = 10, height = 8)

# **************************************************************#
# Top-Right - Collisions with recorded dangerous factors – Faceted pie chart
# **************************************************************#
# Light conditions
light_collisions <- read_csv("./Data/collisions_by_lighting.csv")

ggplot(light_collisions, aes(x = "", y = count, fill = light_conditions)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y") +
  theme_void() +
  labs(title = "Accidents by Light Conditions") +
  theme(legend.position = "right")

ggplot(light_collisions, aes(x = "", y = count, fill = accident_severity)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y") +
  theme_void() +
  labs(title = "Accidents by Light Conditions") +
  theme(legend.position = "right")

# **************************************************************#
# Bottom-Left - Grouped Bar chart of casualties/severities by age/sex
# **************************************************************#
ages <- read_csv("./Data/collisions_by_age.csv")
sexes <- read_csv("./Data/collisions_by_sex.csv")

ggplot(ages, aes(fill=accident_severity, y=count, x=age_band_of_driver)) + 
  geom_bar(position="dodge", stat="identity")+
  theme_minimal() 

# **************************************************************#
# Bottom-Right - UK Heatmap of collisions
# **************************************************************#
# Tests to do:
# - percentage of collisions instead of no.
# - labels for each district
# - better colours/gradient

collisions <- read_csv("./Data/complete_driver_collisions.csv")
districts <- st_read("./Data/LAD_MAY_2024_UK_BUC.shp")

# Getting no. collisions per district
collisions_count <- collisions %>%
  group_by(local_authority_ons_district) %>%
  summarize(collisions = n(), .groups = "drop")

# Joining districts shape file with the number of collisions per district
districts_with_collisions <- districts %>%
  left_join(collisions_count, by = c("LAD24CD" = "local_authority_ons_district"))

collision_heatmap <- ggplot(districts_with_collisions) +
  geom_sf(aes(fill = collisions)) + # Plotting spacial data and using no. collisions for colours
  scale_fill_gradient(low="lightblue", high="red") +
  theme_minimal() +
  theme(axis.text = element_blank(), axis.title = element_blank(), axis.ticks = element_blank()) +
  labs(title = "Heatmap of Collisions by District")

collision_heatmap

ggsave("./Visualisations/collision_heatmap.png", plot=collision_heatmap, width = 10, height = 8)

