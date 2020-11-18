# betapart shenanigans --------------------------------------------------------


# Source libs and load simulated data -----------------------------------------

source(here::here("scripts", "r", "00_libs.R"))
sim_df <- read_csv(here("data", "sim", "simulated_df.csv"))
ma_sim_m3 <- readRDS(here("models", "sim", "ma_sim_m3.rds"))

# global color scheme / non-optimized
cat1_col = "#d95f02"
cat2_col = "#7570b3"
cat3_col = "#1b9e77"


# -----------------------------------------------------------------------------

# bring into betapart shape
fixed_df <- sim_df %>% 
  column_to_rownames(var = "team") %>% 
  select(fixed_1,
         fixed_2,
         fixed_3,
         fixed_4,
         fixed_5)

random_df <- sim_df %>% 
  column_to_rownames(var = "team") %>% 
  select(random_1,
         random_2,
         random_3,
         random_4,
         random_5)

# get betapart objects
df.core.fixed <- betapart.core(fixed_df)
df.core.random <- betapart.core(random_df)

# get pairwise distance
df.pair.fixed <- beta.pair(df.core.fixed, index.family = "sorensen")
df.pair.random <- beta.pair(df.core.random, index.family = "sorensen")

# which one is it? beta.sim / beta.sne / beta.sor?
# if beta.sor then

df.pair.fixed.sor <- broom::tidy(df.pair.fixed$beta.sor) %>% 
  rename(team = item1) %>% 
  group_by(team) %>% 
  summarise(distance_fixed_mean = mean(distance), .groups = "drop")

df.pair.random.sor <- broom::tidy(df.pair.random$beta.sor) %>% 
  rename(team = item1) %>% 
  group_by(team) %>% 
  summarise(distance_random_mean = mean(distance), .groups = "drop")

# this way we only get values for team1-15 ?
# this is how ecoRR does it

df.pair.fixed.sor <- as.matrix(beta.pair(df.core.fixed, index.family = "sorensen")$beta.sor)
fixed_similarity <- colMeans(df.pair.fixed.sor, na.rm = T) 

df.pair.random.sor <- as.matrix(beta.pair(df.core.random, index.family = "sorensen")$beta.sor)
random_similarity <- colMeans(df.pair.random.sor, na.rm = T)


# add to sim_df
sim_df_new <- sim_df %>% 
  mutate(fixed_similarity = fixed_similarity,
         random_similarity = random_similarity)

# store
write_csv(sim_df_new, here("data", "sim", "simulated_df_distances.csv"))

# plot -------------------------------------------------------------------------
  
# scale distances
sim_df_new <- sim_df_new %>% 
  mutate(fixed_similarity_s = scale(fixed_similarity),
         random_similarity_s = scale(random_similarity))

# plot 
fe_re <- ggplot(sim_df_new,
       aes(x = fixed_similarity_s,
           y = random_similarity_s)) +
  geom_vline(xintercept = 0, lty = "dashed") +
  geom_hline(yintercept = 0, lty = "dashed") +
  geom_point(alpha = 0.8, size = 3, pch = 21,
             fill = cat3_col) +
  geom_label_repel(aes(label = team),
                   box.padding   = 0.35, 
                   point.padding = 0.5,
                   segment.color = 'grey50') +
  labs(title = "Sørensen distance for fixed & random effect parameters",
       #subtitle = "",
       x = "\n Distance values for random effects",
       y = "Distance values for fixed effects\n ") +
  theme_minimal()

es_fe <- left_join(sim_df_new, 
  spread_draws(ma_sim_m3, r_team[Team,], b_Intercept) %>% 
    mutate(team = Team, b_Intercept = r_team + b_Intercept) %>% 
    group_by(team) %>% 
    summarize(posterior_median = median(b_Intercept), .groups = "drop"), 
  by = "team") %>% 
  ggplot(., 
    aes(x = fixed_similarity_s, y = posterior_median, 
        fill = random_num, color = random_num)) + 
    geom_point(alpha = 0.8, size = 3, pch = 21) +
    geom_label_repel(aes(label = team),
                     box.padding   = 0.35, 
                     point.padding = 0.5,
                     fill = "white",
                     color = "black",
                     segment.color = 'grey50') + 
    labs(title = "Effect size and Sørensen distance for fixed effects",
       #subtitle = "",
       y = "\nES (posterior median)",
       x = "Distance values for fixed effects\n ") +
    theme_minimal()

es_re <- left_join(sim_df_new, 
  spread_draws(ma_sim_m3, r_team[Team,], b_Intercept) %>% 
    mutate(team = Team, b_Intercept = r_team + b_Intercept) %>% 
    group_by(team) %>% 
    summarize(posterior_median = median(b_Intercept), .groups = "drop"), 
  by = "team") %>% 
  ggplot(., 
    aes(x = random_similarity_s, y = posterior_median, 
        fill = fixed_num, color = fixed_num)) + 
    geom_point(alpha = 0.8, size = 3, pch = 21) +
    geom_label_repel(aes(label = team),
                   box.padding   = 0.35, 
                   point.padding = 0.5,
                   fill = "white",
                   color = "black",
                   segment.color = 'grey50') + 
    labs(title = "Effect size and Sørensen distance for random effects",
       #subtitle = "",
       y = "\nES (posterior median)",
       x = "Distance values for random effects\n ") +
    theme_minimal()

# TR: the patchwork of all three doesn't work for me, no idea why
fe_re + es_fe + es_re
