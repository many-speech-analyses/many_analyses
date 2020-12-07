### Info # ---------------------------------------------------------------------
#
## Author:  Timo Roettger (timo.b.roettger @ gmail.com)
#
## Project: Many speech analyses
#
## Description: simulate hypothetical analyses for hypothesis testing analysis
#
## Version: 11/11/2020
# ------------------------------------------------------------------------------

## libraries--------------------------------------------------------------------
source(here::here("scripts", "r", "00_libs.R"))

# load in original data
fruits <- read_csv(here("data", "dataset", "processed_fruits.csv"))

## come up with three options to answer research question:
# Option#1 centered predictor typicality, 
# random intercepts for speakers-only

fruits$mean_typicality_s <- scale(fruits$mean_typicality, scale = F)

xmdl1 <- lmer(duration ~  mean_typicality_s +
                  (1| speaker),
                data = fruits)
# TR: This is rather straightforward

# Option#2 uncentered predictor typicality interacting with color, 
# random intercepts for speakers and objects
xmdl2 <- lmer(duration ~  mean_typicality * colour +
                (1| speaker) +
                (1 | object),
              data = fruits)

# TR: This is complicated immediately: colour is not contrast-coded, 
# So the estimate for mean_typicality will be the estimate for the colour reference
# level. Additionally, is the interaction term relevant for the research question? 
# or just the main effect?
# Solution: Different coding and standardization of typicality. Decision as to
# what coefficient answers the question.

# Option#3 uncentered predictor typicality with additional predictor colour,
# colour is dummy coded, 
# random intercepts for speakers and objects + by-speaker random slopes for mean_typicality

xmdl3 <- lmer(duration ~  mean_typicality + colour +
                (mean_typicality || speaker) +
                (1 | object),
              data = fruits)

# TR: Same situation as above

# extract stuff
m1 <- tidy(xmdl1) %>% 
  select(effect, term, estimate, std.error) %>% 
  filter(effect == "fixed",
         term == "mean_typicality_s") %>% 
  mutate(model = "model1")

m2 <- tidy(xmdl2) %>% 
  select(effect, term, estimate, std.error) %>% 
  filter(effect == "fixed",
         term %in% c("mean_typicality",
                     'mean_typicality:colourgelb',
                     'mean_typicality:colourgruen',
                     'mean_typicality:colourorange',
                     'mean_typicality:colourrot')) %>% 
  mutate(model = "model2")

m3 <- tidy(xmdl3) %>% 
  select(effect, term, estimate, std.error) %>% 
  filter(effect == "fixed",
         term == "mean_typicality") %>% 
  mutate(model = "model3") %>% 
  full_join(m1) %>% 
  full_join(m2) %>% 
  mutate(es = estimate/std.error)



