
{r check-download}
#| label: check-download
#| code-fold: true
#| code-summary: "Code: Need help with the file?"
#| output: false

# If errors, you may set the working directory with this function (uncomment it)
# Check your working directory
# getwd()
# Set your working directory
# setwd("c:/your-path-to-project-folder/")

# Check the file is found
if (file.exists(here("babysteps.qmd"))) {
  print("Babysteps file found!")
} else {
  print("Note! Please check the babysteps.qmd file and your working directory.")
}