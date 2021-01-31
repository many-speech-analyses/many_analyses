Norming study
================

Last update: 2021-01-31

# Overview

This directory contains the files of the norming study, designed to
obtain typicality ratings of re-colored images of everyday objects.

There are 2 subdirectories:

-   The `images/` directory contains the re-colored images used in the
    norming study.
-   The `results/` directory holds an aggregated `tipicality.csv` file
    with the typicality ratings of each image/object for each
    participant.

The `tipicality.csv` file has the following columns:

-   `prolific id`: The participant/trial id.
-   `object`: The name of the object represented in the image.
-   `typicality`: The typicality rating (numeric, `1-100`, `1` = most
    atypical, `100` = most typical).
-   `colour`: The color of the object in the image.

<!-- -->

    ## # A tibble: 2 x 1
    ##   name   
    ##   <chr>  
    ## 1 images 
    ## 2 ratings
