# *****************************************************************************#
# Preparing clean data for visualisations
# *****************************************************************************#
library(tidyverse)
library(dplyr)
library(readxl)

# Reading data to be processed
collisions <- read_csv("./Data/Raw/complete_driver_collisions.csv")
vehicles <- read_csv("./Data/Raw/dft-road-casualty-statistics-vehicle-last-5-years.csv")

points <- read_excel(
  "./Data/Raw/driving-licence-data-sep-2024.xlsx",
  sheet="DRL0131 - September 2024",
  skip=24
)

# *****************************************************************************#
# Times with collision frequencies and severities
# *****************************************************************************#
# Keeping first 2 digits representing the hour
collisions$time <- substr(collisions$time, 1, 2)

# Forming data to be used for time polar chart
hourly_collisions <- collisions %>%
  # Changing accident measures into Fatal and Non-Fatal
  mutate(accident_severity=ifelse(accident_severity == "Fatal", "Fatal", "Non-Fatal")) %>%
  # Grouping by time and then counting the number the number of collisions per hour
  group_by(collisions$time, accident_severity) %>%
  # Counting no. rows per group
  summarise(count=n(), .groups="drop")

# Renaming for better readability and easier to use
colnames(hourly_collisions)[1] <- "time"

# Saving data, will be done for each set of data
write_csv(hourly_collisions, "./Data/Processed/collisions_by_time.csv")

# *****************************************************************************#
# Counts for Safe and Unsafe Driving Conditions
# *****************************************************************************#
# Selecting rows with safe driving conditions and adding overall_conditions column
safe_conditions <- collisions %>%
  filter(light_conditions == 1 | 2,
         weather_conditions == 1,
         road_surface_conditions == 1) %>%
  mutate(overall_conditions="Safe")

# Selecting all rows where conditions are not safe and updating overall_conditions 
unsafe_conditions <- collisions %>%
  filter(!(light_conditions == 1 &
             weather_conditions == 1 &
             road_surface_conditions == 1)) %>%
  mutate(overall_conditions = "Unsafe")

# Combining safe and unsafe conditions and keeping accident serverities
combined_overall_conditions <- bind_rows(safe_conditions, unsafe_conditions)

# Counting the number of collisions by overall conditions and severity
condition_counts <- combined_overall_conditions %>%
  group_by(overall_conditions) %>%
  summarise(collision_count=n())

write_csv(condition_counts, "./Data/Processed/condition_counts.csv")

# *****************************************************************************#
# Counts for Journey Types
# *****************************************************************************#
# Number of journies made for specific purpose
journey_counts <- vehicles %>%
  # Counting the number of each journey type
  count(journey_purpose_of_driver, name="Count") %>%
  # Updating purpose column with un-encoded values
  mutate(
    journey_purpose_of_driver=case_when(
      journey_purpose_of_driver == 1 | journey_purpose_of_driver == 2  ~ "Work",
      journey_purpose_of_driver == 3 | journey_purpose_of_driver == 4  ~ "School",
      journey_purpose_of_driver == 5  ~ "Leisure",
    )) %>%
  # Removing rows where journey reason unknown or not recorded
  filter(!is.na(journey_purpose_of_driver))

write_csv(journey_counts, "./Data/Processed/journey_counts.csv")

# *****************************************************************************#
# Percentage of Points and Collisions by Age
# *****************************************************************************#
# Defining age groups and getting point totals
point_counts <- points %>%
  # Removing first and last row (labels)
  slice(2:(n() - 1)) %>%
  # Removing irrelevant columns
  select(-1, -"Current Pts") %>%
  mutate(Age=as.numeric(`...2`)) %>%
  # Grouping rows by their ages and into new "Age_Group" column
  group_by(Age_Group=case_when(
    Age >= 16 & Age <= 20 ~ "16-20",
    Age >= 21 & Age <= 25 ~ "21-25",
    Age >= 26 & Age <= 35 ~ "26-35",
    Age >= 36 & Age <= 45 ~ "36-45",
    Age >= 46 & Age <= 55 ~ "46-55",
    Age >= 56 & Age <= 65 ~ "56-65",
    Age >= 66 & Age <= 75 ~ "66-75",
    Age > 75 ~ "75+"
  )) %>%
  # Getting point totals
  summarise(No._Points=sum(across(everything(), ~ sum(as.numeric(.))))) %>%
  # Adding new column to be measurement label when combined
  mutate(Measurement="Penalty Points")

# Creating new percentage column and calculating percentages for points
point_percentages <- point_counts %>%
  mutate(Percentage=(No._Points / sum(No._Points)) * 100)

# Moving onto collision data and getting percentage of collisions per age group
collision_percentages <- collisions %>%
  # Number of collisions per age group
  count(age_band_of_driver, name="No._Collisions") %>%
  # Calculating the percentages
  mutate(
    Percentage_of_Collisions=(No._Collisions / sum(No._Collisions)) * 100,
    # Again adding new measurement column for identification when merged
    Measurement="Collisions"
  ) %>%
  rename(Age_Group=age_band_of_driver, Percentage=Percentage_of_Collisions)

# Merging the points and collisions percentages into one data set
all_percentages <- bind_rows(point_percentages, collision_percentages) %>%
  select(Age_Group, Measurement, Percentage)

write_csv(all_percentages, "./Data/Processed/point_and_collisions_by_age.csv")

# *****************************************************************************#
# District Data for Heat map
# *****************************************************************************#
# Getting no. collisions per district
collision_counts <- collisions %>%
  group_by(local_authority_ons_district) %>%
  summarize(collisions=n()) %>%
    mutate(
    percentage_of_collisions =(collisions / sum(collisions)) * 100,
  ) 

write_csv(collision_counts, "./Data/Processed/collisions_per_district.csv")
