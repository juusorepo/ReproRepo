## -----------------------------------------------------------------------------
#| label: load-processed-data-and-packages
#| code-fold: true
#| code-summary: "View code: Load packages and data"
#| warning: false
#| message: false

# install required packages if not already
# tidyverse for data manipulation
if (!requireNamespace("tidyverse", quietly = TRUE)) {install.packages("tidyverse")}
# modelsummary for automating table creation
if (!requireNamespace("modelsummary", quietly = TRUE)) {install.packages("modelsummary")}
# flextable for customising tables
if (!requireNamespace("flextable", quietly = TRUE)) {install.packages("flextable")}
# lme4 package for mixed-effects regression
if (!requireNamespace("lme4", quietly = TRUE)) {install.packages("lme4")}
# broom to create tidy tables
if (!requireNamespace("broom", quietly = TRUE)) {install.packages("broom")}
# report for automating reporting  
if (!requireNamespace("report", quietly = TRUE)) {install.packages("report")}
# tidyverse for data manipulation  
if (!requireNamespace("tidyverse", quietly = TRUE)) {install.packages("tidyverse")}
# here for file management  
if (!requireNamespace("here", quietly = TRUE)) {install.packages("here")}

# load packages
require(modelsummary)
require(flextable)
require(lme4)
require(broom)
require(report)
require(tidyverse)
require(here)

# Load / download data
if (file.exists(here("01-data/processed/babysteps.csv"))) {
  babysteps <- read.csv(here("01-data/processed/babysteps.csv"))
} else {
  babysteps <-
    read.csv(
      "https://raw.githubusercontent.com/juusorepo/ReproRepo/master/01-data/processed/babysteps.csv"
    )
}

# Adjustments for data types and variable names
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
#| label: table1-summary

# First we set flextable defaults to follow APA style,
# so all our tables will have the same default style
set_flextable_defaults(
  font.size = 10,
  font.family = "Times New Roman",
  font.color = "#000000",
  border.color = "#333333",
  background.color = "white",
  padding.top = 4,
  padding.bottom = 4,
  padding.left = 4,
  padding.right = 4,
  height = 1.3, # line height
  digits = 2,
  decimal.mark = ".",
  big.mark = ",",  # thousands separator
  na_str = "NA"
)

# The datasummary function builds a table by reference to a two-sided formula:
# the left side defines rows and the right side defines columns.
tbl_sum <- datasummary(
  `Age (months)` + `Puzzletime (sec)` + `Giggle count` + `Sleep (hours)` ~ # left side: rows
    N + steptype * (Mean + SD),
  # right side: columns, and * for grouping
  output = "flextable",
  data = babysteps_T1
)

# Modification with flextable
# add a spanning header row
tbl_sum <- add_header_row(
  tbl_sum,
  colwidths = c(2, 2, 2, 2),
  values = c("", "Crawling", "Toddling", "Walking")
)
# center align the header row
tbl_sum <- align(tbl_sum,
             i = 1,
             part = "header",
             align = "center")
tbl_sum <- add_footer_lines(tbl_sum, "Add notes here.")

# add a caption
tbl_sum <-
  set_caption(tbl_sum, caption = "Descriptive statistics for baseline data")

# set width of the first column
tbl_sum <- width(tbl_sum, j = 1, width = 1.5)

# adjust the column labels
tbl_sum <- set_header_labels(
  tbl_sum,
  "Crawling / Mean" = "Mean",
  "Crawling / SD" = "SD",
  "Toddling / Mean" = "Mean",
  "Toddling / SD" = "SD",
  "Walking / Mean" = "Mean",
  "Walking / SD" = "SD"
)




## -----------------------------------------------------------------------------
#| label: export-outputs
#| output: false

# To RTF (opens in e.g., Microsoft Word)
save_as_rtf(
  "Descriptive statistics for baseline data" = tbl_sum,
  path = here("05-outputs/tables/tbl1-desc.rtf")
)

# To PowerPoint
save_as_pptx(
  "Descriptive statistics for baseline data" = tbl_sum,
  path = here("05-outputs/tables/tbl1-desc.pptx")
)

# To HTML
save_as_html(tbl_sum, path = here("05-outputs/tables/tbl1-desc.html"))

# To image file
save_as_image(tbl_sum, path = here("05-outputs/tables/tbl1-desc.png"))

# If problems in creating image, install webshot package
# if (!requireNamespace("webshot", quietly = TRUE)) {install.packages("webshot")}
# require(webshot)


## -----------------------------------------------------------------------------
#| label: table2-linear-regression

# Run a linear regression model
model_lm <-
  lm(puzzletime ~ agemonths + sleephours + steptype, data = babysteps)

# Create a tidy table from the model results
tbl_lm <- model_lm %>%
  tidy(conf.int = TRUE) %>% # include confidence intervals
  mutate_if(is.numeric, round, 3) # round numerics to three decimals

# Convert to flextable for customization and export
tbl_lm <- flextable(tbl_lm)

# Customize using flextable
tbl_lm <- tbl_lm %>%
  set_caption("Linear Regression Results") %>%
  set_header_labels(
    term = "Predictor",
    estimate = "Estimate",
    std.error = "Std. Error",
    statistic = "Statistic",
    p.value = "P value",
    conf.low = "CI Lower",
    conf.high = "CI Upper"
  ) %>%
  align(align = "center", part = "all") %>%
  align(align = "left", part = "header")

# Export the table to Word
save_as_rtf(
  "Linear regression results" = tbl_lm,
  path = here("05-outputs/tables/tbl2-lm.rtf")
)




## -----------------------------------------------------------------------------
#| label: table3-mixed-effects

# Model 1: Impact of age, mobility type, and engagement
model1 <- lmer(puzzletime ~ agemonths + steptype + (1|babyid), data = babysteps)

# Model 2: Inclusion of sleep quality
model2 <- lmer(puzzletime ~ agemonths + steptype + gigglecount + (1|babyid), data = babysteps)

# Model 3: Interaction effects
model3 <- lmer(puzzletime ~ agemonths + steptype * gigglecount + (1|babyid), data = babysteps)

# Add models into a list
models <- list("M1" = model1, "M2" = model2, "M3" = model3)

# Create a table with modelsummary
# Specify table title and footnote
title = ""
notes = "Insert notes here."

# Create the table
tbl_mx <- modelsummary(
  models,
  output = 'flextable',  # output as flextable
  stars = TRUE,  # include stars for significance
  gof_map = c("nobs", "r.squared"), # goodness of fit stats to include
  title = title, 
  notes = notes)  

# Autofit cell widths and height
tbl_mx <- autofit(tbl_mx) # Adjust column widths

# Export the table to RTF (e.g., Word)
save_as_rtf(
  "Table 3. Mixed effects model results" = tbl_mx,
  path = here("05-outputs/tables/tbl3-mixed-effects.rtf")
)

# Create a styled version for presentation
tbl_for_ppt <- tbl_mx %>%
  bg(c(5, 7), bg = 'lightblue') %>% # background color in row 1
  color(9, color = 'red') %>% # text color in row 7
  fontsize(size = 10, part = "all") %>% # Font size for all parts of the table
  theme_vanilla() %>% # flextable offers several predefined themes
  height(height = 0.15) # Adjusting the height of the rows, set as needed

# Export the presentation version to Powerpoint
save_as_pptx(
  "Mixed effects model results" = tbl_for_ppt,
  path = here("05-outputs/tables/tbl3-mixed-effects.pptx")
)




## -----------------------------------------------------------------------------
#| label: figure1-coefs

# List coefficients for the figure (rename + reorder) 
# here we plot only main effects for simplicity
coef_map <- c(
  "agemonths" = "Age in months",
  "steptypeToddling" = "Step type: Toddling",
  "steptypeWalking" = "Step type: Walking",
  "gigglecount" = "Giggle count"
)

# Create a coefficient plot
fig1 <- modelplot(
  model2,
  coef_map = rev(coef_map), # rev() reverses list order
  coef_omit = "Intercept", # omit Intercept
  color = "black"
) +
  geom_vline(
    xintercept = 0,
    color = "red",
    linetype = "dashed",
    linewidth = .75 ) + # red 0 line
  theme(
    panel.background = element_rect(fill = "white"), # Ensure background is white
    plot.background = element_rect(fill = "white", color = NA), # No border
    text = element_text(family = "sans-serif", color = "black"), # sans-serif fonts like Arial
    plot.title = element_text(size = 12, face = "bold"), # Title in bold
    plot.caption = element_text(size = 10), # Smaller text for caption
    axis.title = element_text(size = 12), # Axis titles
    axis.text = element_text(size = 10), # Axis text
    legend.title = element_text(size = 12), # Legend title
    legend.text = element_text(size = 10) # Legend text
  ) +
  labs(title = "Figure 1: Predictors of Puzzle Solving Time",
       caption = "Unstandardized coefficients.")

# Export fig1 to a PNG file
ggsave(
  here("05-outputs/figures/fig1-coefs.png"),
  fig1,
  width = 8,
  height = 6,
  dpi = 300
)








## -----------------------------------------------------------------------------
#| label: figure2-interaction

# Prepare data for prediction, focusing on steptype and gigglecount interaction
predict_data_interaction <- expand.grid(
  agemonths = mean(babysteps$agemonths),  # Use mean age to isolate the interaction effect
  steptype = unique(babysteps$steptype),
  gigglecount = seq(min(babysteps$gigglecount), max(babysteps$gigglecount), length.out = 100),
  babyid = unique(babysteps$babyid)[1]
)

# Predict puzzletime using model3 for the interaction between steptype and gigglecount
predict_data_interaction$puzzletime_pred <- predict(model3, newdata = predict_data_interaction, re.form = NA) 

# Adjusting the plot for black and white APA style
interaction_plot <- ggplot(predict_data_interaction, aes(x = gigglecount, y = puzzletime_pred, group = steptype)) +
  geom_line(aes(linetype = steptype), linewidth = 1) +  
  theme_minimal(base_size = 12) + 
  theme(
    legend.title = element_blank(),  
    legend.position = "bottom",  
    plot.title = element_text(face = "bold", size = 14),  
    axis.title = element_text(size = 12),  
    axis.text = element_text(size = 11) 
  ) +
  labs(
    title = "Interaction Effect of Step Type and Giggle Count on Puzzle Solving Time",
    x = "Giggle Count",
    y = "Predicted Puzzle Time (seconds)"
  ) +
  scale_linetype_manual(values = c("solid", "dashed", "dotted"))

# Export the interaction_plot to a PNG file
ggsave(
  filename = here("05-outputs/figures/fig2-interaction.png"),
  plot = interaction_plot,  
  width = 8,
  height = 6,
  dpi = 300,
  bg = "white"  # Ensure a white background 
)

message("Outputs saved in your output -folder") 

