# Imports
library(tidyverse)
library(dplyr)
library(ggplot2)
library(sf)
library(patchwork)
library(viridis)

# *****************************************************************************#
# Top-Left - Collision frequency/severity at time of day
# *****************************************************************************#
hour_per_year_collisions <- read_csv("./Data/Processed/collisions_per_hour_per_year.csv")

# Plotting the trend of years and hours together
hourly_collisions <- ggplot(hour_per_year_collisions, aes(x = time, y = no_collisions, color = as.factor(accident_year), group = accident_year)) +
  geom_line() + 
  geom_point() +
  labs(title = "5 Years of Collisions",
       x = "Hour of Day",
       y = "Number of Collisions",
       colour = "Year") +
  theme_minimal() +
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("./Visualisations/collisions_per_hour_and_year.png", hourly_collisions, width = 9, height = 4)

# *****************************************************************************#
# Top-Right - Driving Factors (Drive Purpose and Conditions)
# *****************************************************************************#
condition_counts <- read_csv("./Data/Processed/condition_counts.csv")

conditions_chart <- ggplot(condition_counts, aes(x="", y=collision_count, fill=overall_conditions)) +
  geom_bar(stat="identity", width=1) +
  coord_polar("y", start=0) +
  labs(y="", fill="Conditions", title="Driving Considerations") + 
  theme_minimal() +
  scale_fill_manual(values=c(Safe="lightgreen", Unsafe="#F8766D")) +
  theme(legend.position = "bottom",
        axis.text=element_blank(), axis.ticks=element_blank(), 
        axis.title=element_blank(), panel.grid=element_blank(),
        plot.title = element_text(hjust = 0.5))

journey_type_counts <- read_csv("./Data/Processed/journey_counts.csv")

journey_chart <- ggplot(journey_type_counts, aes(x="", y=Count, fill=journey_purpose_of_driver, width = 10, height =2)) +
  geom_bar(stat="identity", width=1) +
  coord_polar("y", start=0) +
  labs(y="", fill="Journey") + 
  scale_fill_manual(values=c(Work="#e69138", Leisure="#9c27b0", School="#335676")) +
  theme_minimal() +
  theme(legend.position = "bottom",
        axis.text=element_blank(), axis.ticks=element_blank(),
        axis.title=element_blank(),  panel.grid=element_blank())

driving_factors <- (conditions_chart) / (journey_chart)

ggsave("./Visualisations/driving_factors.png", plot=driving_factors, width=12, height=4)

# *****************************************************************************#
# Bottom-Left - Grouped Bar chart of casualties/severities by age/sex
# *****************************************************************************#
point_collision_percentages <- read_csv("./Data/Processed/point_and_collisions_by_age.csv")

# Grouped bar chart using percentages and measurements
driver_metrics <- ggplot(point_collision_percentages, aes(fill=Measurement, y=Percentage, x=Age_Group)) + 
  geom_bar(position="dodge", stat="identity") +
  labs(x="Driver Age", y="Percent (%)", fill="Metric",
       title="Measuring Risk with Age") +
  theme_minimal() +
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 45))

ggsave("./Visualisations/driver_metrics.png", plot=driver_metrics, width=5, height=4)

# *****************************************************************************#
# Bottom-Right - UK Heat map of collisions
# *****************************************************************************#
districts <- st_read("./Data/Geographical/LAD_MAY_2024_UK_BUC.shp")
collisions_per_districts <- read_csv("./Data/Processed/collisions_per_district.csv")

# Joining districts shape file with the number of collisions per district
districts_with_collisions <- districts %>%
  left_join(collisions_per_districts, by=c("LAD24CD"="local_authority_ons_district")) %>%
  filter(collisions > 0) # Removing areas without recorded collisions

collision_heatmap <- ggplot(districts_with_collisions) +
  # Plotting spacial data and using percentage of collisions for colours
  geom_sf(aes(fill=collisions)) + 
  #scale_fill_gradient(low="lightyellow", high="red") +
  scale_fill_viridis_c() +
  labs(title="Collisions by Area",) +
  theme_minimal() +
  theme(legend.position = "bottom",
        axis.text=element_blank(), axis.title=element_blank(), 
        axis.ticks=element_blank(), panel.grid=element_blank(),
        plot.title = element_text(hjust = 0.5))

ggsave("./Visualisations/collision_heatmap.png", plot=collision_heatmap, width=10, height=8)

# *****************************************************************************#
# Composite Visualisation
# *****************************************************************************#
composite <- (hourly_collisions | collision_heatmap) / (driver_metrics | driving_factors) +
  plot_annotation(title="UK Drivers Over the Past 5 Years")

ggsave("composite_visualisation.png", plot=composite, width=15, height=15, dpi=300)

