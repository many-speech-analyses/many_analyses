Norming study
================

Last update: 2021-03-24

# Overview

This directory contains the files of the norming study, designed to
obtain typicality ratings of re-colored images of everyday objects.

There are 2 subdirectories:

-   The `images/` directory contains the re-colored images used in the
    norming study.
-   The `ratings/` directory holds an aggregated `ratings.csv` file with
    the typicality ratings of each image/object for each participant.

# Ratings

The `ratings.csv` file represents the raw data collected from the
norming experiment and has the following columns:

-   `subject_id`: The participant/trial id.
-   `object`: The name of the object illustrated in the image.
-   `typicality`: The typicality rating (numeric, `1-100`, `1` = most
    atypical, `100` = most typical).
-   `colour`: The color of the object in the image.
-   `object_en`: The english translation of `object`
-   `colour_en`: The english translation of `colour`

The `ratings_summary.csv` represents the aggregated typicality ratings
across combinations of object and color. The file has the following
columns:

-   `object`: The name of the object illustrated in the image.
-   `colour`: The color of the object in the image.
-   `object_en`: The english translation of `object`.
-   `colour_en`: The english translation of `colour`.
-   `typ_mean`: The mean typicality rating.
-   `typ_sd`: The standard deviation of the typicality ratings .
-   `typ_median`: The median typicality rating.
