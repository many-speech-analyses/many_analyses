# Source libs -----------------------------------------------------------------

source(here::here("scripts", "r", "00_libs.R"))



# Load data -------------------------------------------------------------------

sim_df <- read_csv(here("data", "sim", "simulated_df.csv"))







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
  file = here::here("models", "sim", "ma_sim_m0")
)

# Add pooling method
m1_brm <- brm(
  formula = es | se(se) ~ 1 + (1 | study) + (1 | stops), 
  family = gaussian, 
  data = madata,
  prior = priors,
  iter = 4000, warmup = 2000,  cores = 4, chains = 4, 
  control = list(adapt_delta = 0.9999, max_treedepth = 15), 
  file = here::here("models", "meta_analysis_mod_1")
)

# Fit between variable model (add stress)
m2_brm <- brm(
  formula = es | se(se) ~ 0 + Intercept + is_stressed + (1 | study) + (1 | stops), 
  family = gaussian, 
  data = madata,
  prior = c(prior(normal(0, 1), class = b),
            prior(cauchy(0, 1), class = sd)),
  iter = 4000, warmup = 2000,  cores = 4, chains = 4, 
  control = list(adapt_delta = 0.9999), 
  file = here::here("models", "meta_analysis_mod_2")
)

# Add analytic strategy
m3_brm <- brm(
  formula = es | se(se) ~ 0 + Intercept + is_stressed + analytic_str_dev + 
    (1 | study) + (1 | stops), 
  family = gaussian, 
  data = madata,
  prior = c(prior(normal(0, 1), class = b),
            prior(cauchy(0, 1), class = sd)),
  iter = 4000, warmup = 2000,  cores = 4, chains = 4, 
  control = list(adapt_delta = 0.9999), 
  file = here::here("models", "meta_analysis_mod_3")
)

# Assess fit
# pp_check(ma_sim_m0, nsamples = 200)
# pp_check(m1_brm, nsamples = 200)
# pp_check(m2_brm, nsamples = 200)
# pp_check(m3_brm, nsamples = 200)

# -----------------------------------------------------------------------------



# Plots 
posterior_samples(ma_sim_m0, c("^b", "^sd")) %>% 
  rename(smd = b_Intercept, tau = sd_team__Intercept) %>% 
  ggplot(., aes(x = smd, y = tau)) + 
  stat_density_2d(aes(fill = after_stat(level)), geom = "polygon") +
    geom_point(aes(x = median(smd), y = median(tau)), pch = 21, fill = "white") + 
    scale_fill_viridis_c(option = "D", end = 1) +
    labs(y = expression(tau), x = expression(italic("SMD"))) + 
    theme_minimal() + 
    theme(legend.position = "none")


# Get draws for each study
team_draws <- spread_draws(ma_sim_m0, r_team[Team,], b_Intercept) %>% 
  mutate(b_Intercept = r_team + b_Intercept)

# Get draws for pooled effect
pooled_effect_draws <- spread_draws(ma_sim_m0, b_Intercept) %>% 
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
  mean_qi(b_Intercept)

# Plot it all
forest_data %>% 
  ggplot(., aes(x = b_Intercept, y = Team)) +
  geom_vline(xintercept = fixef(ma_sim_m0)[1, 1], color = "darkred", size = 0.7, 
    lty = 3) +
  geom_vline(xintercept = fixef(ma_sim_m0)[1, 3:4], color = "darkred", lty = 3) +
  geom_vline(xintercept = 0, color = "grey30", size = 0.5) +
  stat_halfeye(fill = "#31688EFF", shape = 21, point_fill = "white", 
               point_size = 2, alpha = 1, slab_alpha = 0.9) + 
  geom_text(data = mutate_if(forest_data_summary, is.numeric, round, 2),
            aes(label = glue("{b_Intercept} [{.lower}, {.upper}]"), x = Inf), 
            hjust = "inward", family = "Times") + 
  labs(x = expression(italic("SMD")), y = NULL) +
  theme_minimal() + 
  theme(axis.text.y = element_text(hjust = 0))
