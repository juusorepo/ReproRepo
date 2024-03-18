## -----------------------------------------------------------------------------
#| label: load-processed-data-and-packages
#| warning: false
#| message: false

# install required packages if not already
# tidyverse for data manipulation
if (!requireNamespace("tidyverse", quietly = TRUE)) {install.packages("tidyverse")}
# modelsummary package
if (!requireNamespace("modelsummary", quietly = TRUE)) {install.packages("modelsummary")}
# flextable package
if (!requireNamespace("flextable", quietly = TRUE)) {install.packages("flextable")}
# Load the lme4 package for regression
if (!requireNamespace("lme4", quietly = TRUE)) {install.packages("lme4")}
# broom to create tidy tables
if (!requireNamespace("broom", quietly = TRUE)) {install.packages("broom")}
# Load the report to report the results 
if (!requireNamespace("report", quietly = TRUE)) {install.packages("report")}

# load packages
require(tidyverse)
require(here)
require(modelsummary)
require(flextable)
require(lme4)
require(report)
require(broom)

# Download data IF NOT already available
if (!file.exists(here("01-data/processed/babysteps.csv"))) {
  download.file("https://raw.githubusercontent.com/juusorepo/baby-steps-reproducible-workflow-r/main/01-data/raw/babysteps-rawdata.csv", "babysteps.csv")
}
# load the data
babysteps <- read.csv(here("01-data/processed/babysteps.csv"))

# Some adjustments
# Converting character variables to factors 
babysteps <- babysteps %>% mutate_if(is.character, as.factor)
# Subset data for the baseline measurement (T1)
babysteps_T1 <- babysteps %>% filter(wave == 1)
# rename columns for better readability for outputs
babysteps_T1 <- babysteps_T1 %>%
  rename(
    `Age (months)` = agemonths,
    `Puzzletime (sec)` = puzzletime,
    `Giggle count` = gigglecount,
    `Sleep (hours)` = sleephours
  )




## -----------------------------------------------------------------------------
#| label: tbl-summary

# First we set flextable defaults to follow APA style,
# so all our tables will have the same default style 
set_flextable_defaults(
  font.size = 10, 
  font.family = "Times New Roman",
  font.color = "#000000",
  border.color = "grey",
  background.color = "white",
  padding.top = 4, padding.bottom = 4,
  padding.left = 4, padding.right = 4,
  height = 1.3, # line height
  digits = 2,
  decimal.mark = ".",
  big.mark = ",", # thousands separator
  na_str = "NA"
)

# The datasummary function builds a table by reference to a two-sided formula:
# the left side defines rows and the right side defines columns.
tbl <- datasummary(
  `Age (months)` + `Puzzletime (sec)` + `Giggle count` + `Sleep (hours)` ~ # left side: rows
  N + steptype * (Mean + SD), # right side: columns, and * for grouping
  output = "flextable",
  data = babysteps_T1
)

# Modifying the table, learn more: https://ardata-fr.github.io/flextable-book/
# add a spanning header row
tbl <- add_header_row(tbl,
  colwidths = c(2, 2, 2, 2),
  values = c("", "Crawling", "Toddling", "Walking")
  )
# center align the header row
tbl <- align(tbl, i = 1, part = "header", align = "center")
tbl <- add_footer_lines(tbl, "Add notes here.")

# add a caption
tbl <- set_caption(tbl, caption = "Descriptive statistics for baseline data")

# set width of the first column
tbl <- width(tbl, j = 1, width = 1.5)
# or autofit columns widths
# tbl <- autofit(tbl)

# adjust the column labels
tbl <- set_header_labels(
  tbl,
  "Crawling / Mean" = "Mean",
  "Crawling / SD" = "SD",
  "Toddling / Mean" = "Mean",
  "Toddling / SD" = "SD",
  "Walking / Mean" = "Mean",
  "Walking / SD" = "SD"
)




## -----------------------------------------------------------------------------
#| label: export-outputs

# To RTF (opens in e.g., Microsoft Word)
save_as_rtf(
  "Descriptive statistics for baseline data" = tbl, 
  path = here("05-outputs/tables/tbl1-desc.rtf"))

# To PowerPoint
save_as_pptx(
  "Descriptive statistics for baseline data" = tbl, 
  path = here("05-outputs/tables/tbl1-desc.pptx"))

# To HTML
save_as_html(tbl, path = here("05-outputs/tables/tbl1-desc.html"))

# To image file
save_as_image(tbl, path = here("05-outputs/tables/tbl1-desc.png"))

# If problems in creating image, install webshot package 
# if (!requireNamespace("webshot", quietly = TRUE)) {install.packages("webshot")}
# require(webshot)


## -----------------------------------------------------------------------------
#| label: tbl-linear-regression

# Run a linear regression model
model_lm <- lm(puzzletime ~ agemonths + sleephours, data = babysteps)

# Create a tidy table from the model results
tbl_lm <- model_lm %>%
  tidy(conf.int = TRUE) %>% # include confidence intervals
  mutate_if(is.numeric, round, 3) # round numerics to three decimals

# Convert to flextable for customization and export  
tbl_lm <- flextable(tbl_lm)

# Customize using flextable 
tbl_lm <- tbl_lm %>%
  set_caption("Linear Regression Results") %>%
  set_header_labels(term = "Predictor", estimate = "Estimate", std.error = "Std. Error", 
                    statistic = "Statistic", p.value = "P value", conf.low = "CI Lower", conf.high = "CI Upper") %>%
  align(align = "center", part = "all") %>%
  align(align = "left", part = "header")

# Export the table to Word
save_as_rtf(
  "Linear regression results" = tbl_lm, 
  path = here("05-outputs/tables/tbl2-lm.rtf"))




## -----------------------------------------------------------------------------
#| label: tbl-mixed-effects

# Model 1: Basic Effect of Age
model1 <- lm(puzzletime ~ agemonths, data = babysteps)

# Model 2: Age and Mobility Type
model2 <- lm(puzzletime ~ agemonths + steptype, data = babysteps)

# Model 3: Age, Mobility Type, and Sleep Quality
model3 <- lm(puzzletime ~ agemonths + steptype + sleephours, data = babysteps)

# Add models into a list
models <- list("M1" = model1,"M2" = model2, "M3" = model3)

# Create a table with modelsummary
# Specify table title and footnote
title = "" 
notes = "Insert notes here."     

# Rename and/or reorder coefficients for the table
coef_map <- c(
        "agemonths" = "Age in months",  
        "steptypeToddling" = "Step type: Toddling",   
        "steptypeWalking" = "Step type: Walking",
        "sleephours" = "Sleeptime in hours",
        "(Intercept)" = "Intercept")

# Create the table 
tbl <- modelsummary(models,               # display the table
             output = 'flextable',        # output as flextable
             stars = TRUE,                # include stars for significance
             gof_map = c("nobs", "r.squared"),         # goodness of fit stats to include   
             coef_map = coef_map,         # coefficient mapping
             title = title,             # title
             notes = notes)           # source note

# Autofit cell widths and height
tbl <- autofit(tbl) # Adjust column widths

# Export the table to RTF (e.g., Word)
save_as_rtf(
  "Table 3. Mixed effects model results" = tbl, 
  path = here("05-outputs/tables/tbl3-mixed-effects.rtf"))

# Create a styled version for presentation
tbl_for_ppt <- tbl %>%
    bg(c(3,5), bg = 'lightblue') %>% # background color in row 1
    color(7, color = 'red') %>% # text color in row 7
  fontsize(size = 10, part = "all") %>% # Font size for all parts of the table
  theme_vanilla() # flextable offers several predefined themes 
  
# Export the presentation version to Powerpoint
save_as_pptx(
  "Mixed effects model results" = tbl_for_ppt, 
  path = here("05-outputs/tables/tbl3-mixed-effects.pptx"))


## -----------------------------------------------------------------------------
#| label: fig-coefs

# Create a coefficient plot 
fig1 <- modelplot(model3, 
          coef_map = rev(coef_map), # rev() reverses list order
          coef_omit = "Intercept", # omit Intercept 
          color = "blue") + 
  geom_vline(xintercept = 0, color = "red", linetype = "dashed", linewidth = .75) + # red 0 line
  theme(panel.background = element_rect(fill = "white"), # Set plot panel background to white
        plot.background = element_rect(fill = "white", color = NA)) + # Set the plot background to white, remove border
  labs(
    title = "Figure 1: Predictors of Puzzle Solving Time",
    caption = "Insert notes here."
  )

fig1 <- modelplot(model3, 
          coef_map = rev(coef_map), # rev() reverses list order
          coef_omit = "Intercept", # omit Intercept 
          color = "blue") + 
  geom_vline(xintercept = 0, color = "red", linetype = "dashed", linewidth = .75) + # red 0 line
  theme(panel.background = element_rect(fill = "white"), # Ensure background is white
        plot.background = element_rect(fill = "white", color = NA), # No border
        text = element_text(family = "sans-serif", color = "black"), # sans-serif fonts like Arial
        plot.title = element_text(size = 12, face = "bold"), # Title in bold
        plot.caption = element_text(size = 10), # Smaller text for caption
        axis.title = element_text(size = 12), # Axis titles
        axis.text = element_text(size = 10), # Axis text
        legend.title = element_text(size = 12), # Legend title
        legend.text = element_text(size = 10) # Legend text
        ) + 
  labs(
    title = "Figure 1: Predictors of Puzzle Solving Time",
    caption = "Insert notes here."
  )

# Export fig1 to a PNG file
ggsave(here("05-outputs/figures/fig1-coefs.png"), fig1, width = 8, height = 6, dpi = 300)








## -----------------------------------------------------------------------------
#| label: fig-interaction

# Generate a data frame for predictions
predict_data <- expand.grid(agemonths = seq(min(babysteps$agemonths), max(babysteps$agemonths), length.out = 100),
                            steptype = unique(babysteps$steptype),
                            babyid = unique(babysteps$babyid)[1])  # Use a representative babyid

# Predict puzzletime using the model
predict_data$puzzletime_pred <- predict(model2, newdata = predict_data, re.form = NA)  # Fixed effects only


# Plotting observed data points
ggplot(babysteps, aes(x = agemonths, y = puzzletime, color = steptype)) +
#  geom_point(alpha = 0.5) +
  # Add predicted lines from the model
  geom_line(data = predict_data, aes(x = agemonths, y = puzzletime_pred, color = steptype), linewidth = 1) +
  # Add a smooth line through the observed data for comparison
  theme_minimal() +
  labs(title = "Interaction of Age and Step Type on Puzzle Time",
       x = "Age in Months",
       y = "Puzzle Time (minutes)") +
  scale_color_brewer(palette = "Set1")

# Export fig1 to a PNG file
ggsave(here("05-outputs/figures/fig2-interaction.png"), fig1, width = 8, height = 6, dpi = 300)


