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
group_by_severity_variable <- function(variable, view_data=TRUE){
  grouped_collisions <- collisions %>%
    mutate(accident_severity = ifelse(accident_severity == "Fatal", "Fatal", "Non-Fatal")) %>%
    group_by(collisions[[variable]], accident_severity) %>%
    summarise(count = n(), .groups = "drop") # Counting no. rows per group
  
  # Renaming column for improved readability
  colnames(grouped_collisions)[1] <- variable
  
  if (view_data){
    print(grouped_collisions)
    view(grouped_collisions)
  }
  
  return(grouped_collisions)
}

# **************************************************************#
# Times with collision frequencies and severities
# **************************************************************#
# Grouping rows by un-rounded time
time_frequencies <- group_by_severity_variable("time")

# Grouping rows by rounded time
collisions$time <- substr(collisions$time, 1, 2)
time_frequencies <- group_by_severity_variable("time")

write_csv(time_frequencies, "./Data/collisions_by_time.csv")

# **************************************************************#
# Light conditions
# **************************************************************#
# Minimising light conditions into darkness and daylight
collisions$light_conditions <- gsub("Darkness.*", "Darkness", collisions$light_conditions)

# Severity totals
collision_lighting <- group_by_severity_variable("light_conditions")

write_csv(collision_lighting, "./Data/collisions_by_lighting.csv")

# **************************************************************#
# Weather conditions
# **************************************************************#
# Minimising weather into good and bad conditions

# Severity totals
collision_weather <- group_by_severity_variable("weather_conditions")

# **************************************************************#
# Road Conditions
# **************************************************************#
# Grouping by road conditions
collision_road <- group_by_severity_variable("road_surface_conditions")

# Grouping by sex of driver
collision_driver_sex <- group_by_severity_variable("sex_of_driver")

write_csv(collision_driver_sex, "./Data/collisions_by_sex.csv")

# Grouping by age of driver
collision_driver_age <- group_by_severity_variable("age_band_of_driver")

write_csv(collision_driver_age, "./Data/collisions_by_age.csv")

# Grouping by districts
collision_district <- group_by_severity_variable("local_authority_ons_district")

write_csv(collision_district, "./Data/collisions_by_district.csv")

