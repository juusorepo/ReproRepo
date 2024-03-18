
# Codebook for Longitudinal Baby Steps Dataset

## Dataset Overview

**Title:** Longitudinal Study on Baby Steps and Developmental Progress

**Description:** The dataset follows 100 baby participants across three observation points to monitor how their mobility type (Crawling, Toddling, Walking) affects their ability to solve puzzles and their engagement with the task, as indicated by their giggle counts. The data has three three observation points for each baby. The data is simulated for planning a (fictional) study.

**Author:** Jane Doe

**Creation Date:** March 11, 2024

**Last Updated:** March 12, 2024

**Version:** 1.0

## Contact Information

**Author Contact:** Jane Doe (email)

**Institution:** University of Data Science

## License

This dataset is made available under the [Creative Commons Attribution 4.0 International License (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/). Users are free to share and adapt the material for any purpose, even commercially, under the following terms: appropriate credit must be given, a link to the license provided, and indication if changes were made.

## Citation

Please cite this dataset as:

Doe, J. (2024). Longitudinal Study on Baby Steps and Developmental Progress. University of Data Science. Version 1.0. [DOI or URL]

## Variables

-   BabyID
    -   Description: Unique identifier for each baby participant.
    -   Type: Integer
    -   Example Values: 1, 2, 3, ..., 100
-   StepType
    -   Description: The type of mobility the baby is primarily using at the time of observation.
    -   Type: Categorical
    -   Possible Values: Crawling, Toddling, Walking
-   AgeMonths
    -   Description: Age of the baby at the time of observation, in months.
    -   Type: Integer
    -   Range: 12-24 months
-   ObservationPoint
    -   Description: The stage of observation in the longitudinal study.
    -   Type: Categorical
    -   Possible Values: Start (12-14 months), Midway (15-20 months), End (21-24 months)
-   PuzzleTime
    -   Description: Time it takes for the baby to solve a simple puzzle, measured in seconds.
    -   Type: Numeric
    -   Example Values: Values can range based on puzzle difficulty and baby's skill level.
-   GiggleCount
    -   Description: Number of times the baby giggles while solving the puzzle. Used as a proxy for enjoyment or engagement.
    -   Type: Integer
    -   Example Values: Non-negative values, varying by individual and task.

### Collection Method

Data were collected through direct observation of baby participants in a controlled environment, ensuring that puzzle difficulty was consistent across observations.

## Use Cases

This dataset is intended for research on early childhood development, specifically examining the relationship between motor skills, problem-solving abilities, and engagement in activities.

## Ethics Approval

This study received ethics approval from the Institutional Review Board at the University of Data Science, approval number #12345.

## Acknowledgements

We thank the participants and their families for their time and contribution to this study. This research was supported by the Early Development Research Grant #67890.

