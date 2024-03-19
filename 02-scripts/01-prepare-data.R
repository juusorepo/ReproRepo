## -----------------------------------------------------------------------------
#| label: setup_prepare
#| code-fold: true
#| code-summary: "View code: Load packages and data"
#| output: false

# Load required packages
require(here)
require(tidyverse)

# Load / download data
if (file.exists(here("01-data/raw/babysteps-rawdata.csv"))) {
  dataset <- read.csv(here("01-data/raw/babysteps-rawdata.csv"))
} else {
  dataset <-
    read.csv(
      "https://raw.githubusercontent.com/juusorepo/ReproRepo/master/01-data/raw/babysteps-rawdata.csv"
    )
}




## -----------------------------------------------------------------------------
#| label: modify-data-types

# Converting character variables to factors
dataset <- dataset %>% mutate_if(is.character, as.factor)




## -----------------------------------------------------------------------------
#| label: Missing-values
#| include: false
# insert your code here or delete the section


## -----------------------------------------------------------------------------
#| label: Correcting Errors


## -----------------------------------------------------------------------------
#| label: Handling Outliers


## -----------------------------------------------------------------------------
#| label: Standardize Variable Names

# lowercase all variables (good practice)
dataset <- dataset %>% rename_all(tolower)


## -----------------------------------------------------------------------------
#| label: Recoding variables

# Recode wave into an integer for regression analyses
dataset$wave <- as.integer(gsub("T", "", dataset$wave))

# create a new categorical variable AgeGroup
dataset <- dataset %>%
  mutate(agegroup = case_when(
    agemonths <= 14 ~ "12-14 months",
    agemonths <= 20 ~ "15-20 months",
    TRUE ~ "21-24 months"
  ))




## -----------------------------------------------------------------------------
#| label: Save dataset
# Save in CSV format into processed data -subfolder
write.csv(dataset, here("01-data/processed/babysteps.csv"), row.names = FALSE)
message("The processed dataset was saved in processed data folder")

