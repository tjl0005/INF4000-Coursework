# **************************************************************#
# Preparing clean data for visualisations
# **************************************************************#
# Imports
library(tidyverse)
library(dplyr)

collisions <- read_csv("./Data/complete_driver_collisions.csv")

# Function will group severities by given variable within the collision data.
# By default it will open a view of the grouped data in R and save it. To avoid
# this pass view_data=FALSE and/or save_data=FALSE.
group_by_severity_variable <- function(variable, view_data=TRUE, save_data=TRUE){
  grouped_collisions <- collisions %>%
    group_by(collisions[[variable]], accident_severity) %>%
    summarise(count = n(), .groups = "drop") %>% # Counting no. rows per group
    pivot_wider(names_from = accident_severity, values_from = count, values_fill = list(count = 0)) # Creating severity count columns
  
  # Renaming column for improved readability
  colnames(grouped_collisions)[1] <- variable
  
  if (view_data){
    view(grouped_collisions)
  }
  if (save_data){
    write_csv(grouped_collisions, paste0("./Data/", variable, "_collisions.csv"))
  }
  
  return(grouped_collisions)
}

# Removing minutes from time, only need the hour for plot
collisions$time <- substr(collisions$time, 1, 2)

# Grouping rows by time
time_frequencies <- group_by_severity_variable("time")

# Grouping by light conditions
collision_lighting <- group_by_severity_variable("light_conditions")

# Grouping by weather conditions
collision_weather <- group_by_severity_variable("weather_conditions")

# Grouping by road conditions
collision_road <- group_by_severity_variable("road_surface_conditions")

# Grouping by sex of driver
collision_driver_sex <- group_by_severity_variable("sex_of_driver")

# Grouping by age of driver
collision_driver_age <- group_by_severity_variable("age_band_of_driver")

# Grouping by districts
collision_district <- group_by_severity_variable("local_authority_district")
