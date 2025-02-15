# INF4000-Coursework
### Summary
This repository contains the R code and visualisations produced that were completed as coursework for the INF4000 module at the University of Sheffield. The particular purpose of this project is to communicate the causes and impact of dangerous driving in the UK.

The composite visualisation is made up of the following:  
1. Driving Risks with Age - A grouped bar chart showing the percentages of collisions and penalty points for each age group of drivers. 
2. Driving Considerations - A faceted pie chart to show the number of collisions in safe and unsafe conditions and the proportion of collisions for different journey types.
3. Collisions by area - A heatmap showing the frequency of collisions in different UK districts.
4. Collisions of the last 5 years - A line chart showing the percentage of collisions occuring at each hour of the day across the last 5 years.

All the visualisations both separately and as a composite visualisation are available in the "Visualisations Folder".

### Running the code
The intened way to run the code is to first run preprocessing.R and then visualisation.R. Doing this will generate the required data for the visualisations first and then save the composite visualisation into the visualisation directory.

Doing this does require the data to be downloaded already and in the "Raw" folder, with details below.

### The Data
The data used is not directly available due to it's size but can be recreated using the provided links to the original data and running the R files in this repository. The data is cleaned and pre-processed as part of another project (available here) but further processing is done here in this repository for the visualisations.

The original driving license data used in this project is available at: https://www.data.gov.uk/dataset/d0be1ed2-9907-4ec4-b552-c048f6aec16a/gb-driving-licence-data. For this project only the datasheets pertaining to penalty points across gender, ages and location are used.

The original collisions and casualty data is available at: https://www.data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-safety-data.

The geographical data used for the heat map is available at: https://geoportal.statistics.gov.uk/datasets/ons::local-authority-districts-may-2024-boundaries-uk-buc-2/about.

When trying to use the code, your Data directory should be formatted as such otherwise it may not run as intended:
```
+---Geographical
|       LAD_MAY_2024_UK_BUC.dbf
|       LAD_MAY_2024_UK_BUC.shp
|       LAD_MAY_2024_UK_BUC.shx
|       
+---Processed
|       collisions_by_time.csv
|       collisions_per_district.csv
|       collisions_per_hour_per_year.csv
|       condition_counts.csv
|       journey_counts.csv
|       point_and_collisions_by_age.csv
|       
\---Raw
        complete_driver_collisions.csv
        dft-road-casualty-statistics-vehicle-last-5-years.csv
        driving-licence-data-sep-2024.xlsx
```