# Imports
library(tidyverse)
library(dplyr)

list.files("../Visulisation Data")

# Reading data
example_data <-read_csv("../Visulisation Data/xzy.csv")

# Top-Left - Collision frequency/severity at time of day – Circular time plot
# - number of collisions per hour
# 

# Top-Right - Collisions with recorded dangerous factors – Faceted pie chart


# Bottom-Left - Number of casualties and severities by age/sex – Grouped bar chart


# Bottom-Right - Number of collisions by local authority district - Heat map on UK map
