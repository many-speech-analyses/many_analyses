# Meta-analysis of simulated data ---------------------------------------------
#
# Last update: 20201115
# About: This script loads simulated data and uses brms to conduct a 
#        meta-analysis
#
# -----------------------------------------------------------------------------

# Source libs and load simulated data -----------------------------------------
source(here::here("scripts", "r", "00_libs.R"))
sim_df <- read_csv(here("data", "sim", "simulated_df.csv"))

# -----------------------------------------------------------------------------




# Bayesian meta analysis ------------------------------------------------------

# Set priors
priors <- c(prior(normal(0, 1), class = Intercept),
            prior(cauchy(0, 1), class = sd))

# Fit model
ma_sim_m0 <- brm(
  formula = es | se(se) ~ 1 + (1 | team), 
  family = gaussian, 
  data = sim_df,
  prior = priors,
  iter = 4000, warmup = 2000, cores = 4, chains = 4, 
  file = here("models", "sim", "ma_sim_m0")
)

# Add pooling method
ma_sim_m1 <- brm(
  formula = es | se(se) ~ 1 + (1 | team) + (1 | reviewer), 
  family = gaussian, 
  data = sim_df,
  prior = priors,
  iter = 4000, warmup = 2000,  cores = 4, chains = 4, 
  control = list(adapt_delta = 0.9999), 
  file = here("models", "sim", "ma_sim_m1")
)

# Fit between variable model (add posthoc)
ma_sim_m2 <- brm(
  formula = es | se(se) ~ 0 + Intercept + posthoc + 
    (1 | team) + (1 | reviewer), 
  family = gaussian, 
  data = sim_df,
  prior = c(prior(normal(0, 1), class = b),
            prior(cauchy(0, 1), class = sd)),
  iter = 4000, warmup = 2000,  cores = 4, chains = 4, 
  control = list(adapt_delta = 0.9999), 
  file = here("models", "sim", "ma_sim_m2")
)

# Add nmodels
ma_sim_m3 <- brm(
  formula = es | se(se) ~ 0 + Intercept + posthoc + nmodels + 
    (1 | team) + (1 | reviewer), 
  family = gaussian, 
  data = sim_df,
  prior = c(prior(normal(0, 1), class = b),
            prior(cauchy(0, 1), class = sd)),
  iter = 4000, warmup = 2000,  cores = 4, chains = 4, 
  control = list(adapt_delta = 0.9999), 
  file = here("models", "sim", "ma_sim_m3")
)

# Assess fit
# pp_check(ma_sim_m0, nsamples = 200)
# pp_check(ma_sim_m1, nsamples = 200)
# pp_check(ma_sim_m2, nsamples = 200)
# pp_check(ma_sim_m3, nsamples = 200)

# -----------------------------------------------------------------------------




# Plots -----------------------------------------------------------------------

# Pooled effect and SE
posterior_samples(ma_sim_m1, c("^b", "^sd")) %>% 
  rename(smd = b_Intercept, tau = sd_team__Intercept) %>% 
  ggplot(., aes(x = smd, y = tau)) + 
  stat_density_2d(aes(fill = after_stat(level)), geom = "polygon") +
    geom_point(aes(x = median(smd), y = median(tau)), pch = 21, fill = "white") + 
    scale_fill_viridis_c(option = "D", end = 1) +
    labs(y = expression(tau), x = expression(italic("SMD"))) + 
    theme_minimal() + 
    theme(legend.position = "none")




# Grouping variable variability (team, reviewer)
posterior_samples(ma_sim_m3) %>% 
  select(starts_with("sd")) %>% 
  gather(key, tau) %>% 
  mutate(key = str_remove(key, "sd_") %>% 
           str_remove(., "__Intercept")) %>% 
  ggplot(aes(x = tau, fill = key)) +
  geom_density(color = "transparent", alpha = 0.6) +
  scale_fill_viridis_d(name = "Group-level variance", option = "D", end = 0.6, 
    labels = c("Reviewer", "Team")) + 
  labs(y = "Density", x = expression(tau)) + 
  theme_minimal() + 
  theme(legend.position = c(0.85, 0.75), legend.title = element_text(size = 9), 
    legend.text = element_text(size = 8), legend.key.size = unit(0.5, "cm"))




# Plot effect of posthoc and nmodels
posterior_samples(ma_sim_m3) %>% 
  select(b_posthoc, b_nmodels) %>% 
  pivot_longer(cols = everything(), names_to = "parameter", 
    values_to = "estimate") %>% 
  ggplot(aes(x = estimate, y = parameter)) + 
  geom_vline(xintercept = 0, color = "grey30", lty = 3) +
  stat_halfeye(aes(shape = parameter, fill = parameter), 
    point_interval = median_qi, 
    .width = c(.66, .95), slab_alpha = 0.9, 
    slab_color = "transparent", point_fill = "white") +
  scale_fill_viridis_d(name = "Overall effect of", end = .6, 
    guide = guide_legend(reverse = T), 
    labels = c("n models", "posthoc")) + 
  scale_shape_manual(values = c(21:22), guide = F) + 
  labs(x = expression(beta), y = " ") +
  theme_minimal() + 
  theme(legend.position = c(0.9, 0.75), axis.text.y = element_blank(), 
    legend.title = element_text(size = 9), 
    legend.text = element_text(size = 8), 
    legend.key.size = unit(0.5, "cm")) + 
  guides(fill = guide_legend(override.aes = list(shape = NA), reverse = T))




# Forrest plot of teams
# Get draws for each study
team_draws <- spread_draws(ma_sim_m3, r_team[Team,], b_Intercept) %>% 
  mutate(b_Intercept = r_team + b_Intercept)

# Get draws for pooled effect
pooled_effect_draws <- spread_draws(ma_sim_m3, b_Intercept) %>% 
  mutate(Team = "Pooled Effect")

# Combine it and clean up
forest_data <- bind_rows(team_draws, pooled_effect_draws) %>% 
  ungroup() %>%
  mutate(Team = str_replace_all(Team, "[.]", " "), 
         Team = str_replace_all(Team, "et al", "et al.")) %>% 
  mutate(Team = reorder(Team, b_Intercept), 
         Team = relevel(Team, "Pooled Effect", after = Inf))

# Calculate mean qi intervals for right margin text
forest_data_summary <- group_by(forest_data, Team) %>% 
  mean_qi(b_Intercept, .width = c(0.5,0.8,0.95)) %>% 
  mutate_if(is.numeric, round, 2)

# Get pooled effects
pooled_effects_summary <- forest_data_summary %>% 
  filter(Team == "Pooled Effect")

# Plot it all
forest_data %>% 
  ggplot(., aes(x = b_Intercept)) +
  #geom_vline(xintercept = fixef(ma_sim_m3)[1, 3:4], color = "darkred", lty = 3) +
  #geom_vline(xintercept = 0, color = "grey30", size = 0.5) +
  geom_rect(data = pooled_effects_summary %>% filter(.width == 0.5),
            aes(xmin = .lower, xmax = .upper, 
                ymin = -Inf, ymax = Inf), 
            fill = "#4A978A",
            alpha = 0.5) +
  geom_rect(data = pooled_effects_summary %>% filter(.width == 0.8),
            aes(xmin = .lower, xmax = .upper, 
                ymin = -Inf, ymax = Inf), 
            fill = "#4A978A",
            alpha = 0.4) +
  geom_rect(data = pooled_effects_summary %>% filter(.width == 0.95),
            aes(xmin = .lower, xmax = .upper, 
                ymin = -Inf, ymax = Inf), 
            fill = "#4A978A",
            alpha = 0.3) +
  geom_vline(xintercept = fixef(ma_sim_m3)[1, 1], 
             color = "#40758B", size = 0.7, 
             lty = "dashed") +
  geom_pointinterval(data = forest_data_summary %>% 
                       filter(.width != 0.5, Team != "Pooled Effect"), 
                     aes(y = fct_reorder(Team, b_Intercept),
                         xmin = .lower, xmax = .upper),
                     interval_size_range = c(0.5, 1.5),
                     point_size = 2) +
  geom_text(data = forest_data_summary %>% 
              filter(.width == 0.95, Team != "Pooled Effect"),
            aes(y = fct_reorder(Team, b_Intercept),
                label = glue("{b_Intercept} [{.lower}, {.upper}]"), 
                x = Inf), 
            hjust = "inward", family = "Times") + 
  labs(title = "Forest plot of individual team estimates",
       subtitle = "dashed line = meta-analytical estimate / green zones = 50/80/95% CrI",
       x = expression(italic("SMD")), 
       y = NULL) +
  xlim(c(min(forest_data_summary$.lower) * 1.5,
         max(forest_data_summary$.upper)* 1.5)) +
  theme_minimal() + 
  theme(axis.text.y = element_text(hjust = 0))

# -----------------------------------------------------------------------------
