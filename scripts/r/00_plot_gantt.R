# GANTT chart for RR ----------------------------------------------------------
#
# Last update: 20200917
# About: This script produces a gantt chart of our project timeline
#        The plot is produced using ganttrify: 
#        https://github.com/giocomai/ganttrify
#
# -----------------------------------------------------------------------------



# Source libs -----------------------------------------------------------------

source(here::here("scripts", "r", "00_libs.R"))

# -----------------------------------------------------------------------------




# Create timeline df ----------------------------------------------------------

# This is proof of concept, will change
time_line_df <- tribble(
  ~'wp',                ~'activity',          ~'start_date',  ~'end_date',
  "Initiating authors", "Recruiting",         "2021-02-01",   "2021-04-01",
  "Analysis teams",     "Survey",             "2021-04-01",   "2021-04-15",
  "Analysis teams",     "Analysis",           "2021-04-15",   "2021-06-15",
  "Analysis teams",     "Post-Survey",        "2021-06-15",   "2021-06-30",
  "Reviewer",           "Review Analyses",    "2021-07-01",   "2021-07-31",
  "Initiating authors", "Final Analysis",     "2021-08-01",   "2021-08-30",
  "Initiating authors", "Write-Up",           "2021-09-01",   "2021-10-15",
  # hacky way of having three rows for all teams doing the write up
  "Analysis teams",     "Write-Up ",          "2021-09-01",   "2021-10-15",
  "Reviewer",           "Write-Up  ",         "2021-09-01",   "2021-10-15"
)

# "Spots" can be used to mark when things actually occur on expected timeline
# Not used for now ("X" implies something is finished)
time_line_spots <- tribble(
  ~'activity',           ~'spot_type', ~'spot_date', 
  "Data visualisation",  "X",         "2020-10-30", 
  "Writing",             "X",         "2020-10-31"
)

# -----------------------------------------------------------------------------








# Generate and save plot ------------------------------------------------------

p_project_timeline <- ganttrify(
  project = time_line_df,
  #spots = time_line_spots,
  by_date = TRUE,
  exact_date = TRUE,
  colour_palette = c("#FDE624", "#1EA385", "#450D53"),
  size_text_relative = 1.2,
  month_number = FALSE,
  font_family = "Times"
) +
  theme(axis.text.y = element_text(hjust = 0))


devices        <- c('pdf', 'png')
path_gantt     <- file.path(here("figs"), "project_timeline.")

walk(devices, ~ ggsave(filename = glue(path_gantt, .x), 
                       plot = p_project_timeline, device = .x, 
                       height = 5, width = 9, units = "in"))

# -----------------------------------------------------------------------------
