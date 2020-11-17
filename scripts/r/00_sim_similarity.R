# betapart shenanigans --------------------------------------------------------


# Source libs and load simulated data -----------------------------------------

source(here::here("scripts", "r", "00_libs.R"))
sim_df <- read_csv(here("data", "sim", "simulated_df.csv"))

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

# add to sim_df
sim_df_new <- full_join(sim_df, df.pair.fixed.sor) %>% 
  full_join(df.pair.random.sor)

# store
write_csv(sim_df_new, here("data", "sim", "simulated_df_distances.csv"))




# Playing around

# multiple site measures
df.multi <- beta.multi(df.core)

# sampling across equal sites
df.samp <- beta.sample(df.core, sites = 16, samples=100)

# plotting the distributions of components
df.dist <- df.samp$sampled.values

plot(density(df.dist$beta.SOR), xlim = c(0, 0.8), ylim = c(0, 29), 
  xlab = 'Beta diversity', main = '', lwd = 3)
lines(density(df.dist$beta.SNE), lty = 1, lwd = 2)
lines(density(df.dist$beta.SIM), lty = 2, lwd = 2)

# pairwise 
pair.s <- beta.pair(df3)

# plotting clusters
dist.df <- df.samp$sampled.values

plot(hclust(pair.s$beta.sim, method = "average"), 
  hang = -1, main ='', sub = '', xlab = '')
title(xlab = expression(beta[sim]), line=0.3)

plot(hclust(pair.s$beta.sne, method = "average"), 
  hang = -1, main = "", sub = "", xlab = "")
title(xlab = expression(beta[sne]), line = 0.3)
















# Tutorial from betapart article
data(ceram.s)
data(ceram.n)

# get betapart objects
ceram.s.core <- betapart.core(ceram.s)
ceram.n.core <- betapart.core(ceram.n)

# multiple site measures
ceram.s.multi <- beta.multi(ceram.s.core)
ceram.n.multi <- beta.multi(ceram.n.core)

# sampling across equal sites
ceram.s.samp <- beta.sample(ceram.s.core, sites=10, samples=100)
ceram.n.samp <- beta.sample(ceram.n.core, sites=10, samples=100)

# plotting the distributions of components
dist.s <- ceram.s.samp$sampled.values
dist.n <- ceram.n.samp$sampled.values

plot(density(dist.s$beta.SOR), xlim = c(0, 0.8), ylim = c(0, 29), 
  xlab = 'Beta diversity', main = '', lwd = 3)
lines(density(dist.s$beta.SNE), lty=1, lwd=2)
lines(density(dist.s$beta.SIM), lty=2, lwd=2)
lines(density(dist.n$beta.SOR), col = 'grey60', lwd=3)
lines(density(dist.n$beta.SNE), col='grey60', lty = 1, lwd = 2)
lines(density(dist.n$beta.SIM), col='grey60', lty = 2, lwd = 2)

# pairwise for south
pair.s <- beta.pair(ceram.s)

# plotting clusters
dist.s <- ceram.s.samp$sampled.values
dist.n <- ceram.n.samp$sampled.values

plot(hclust(pair.s$beta.sim, method = "average"), 
  hang = -1, main ='', sub = '', xlab = '')
title(xlab = expression(beta[sim]), line=0.3)

plot(hclust(pair.s$beta.sne, method = "average"), 
  hang = -1, main = "", sub = "", xlab = "")
title(xlab = expression(beta[sne]), line = 0.3)



data(bbsData)

bbs.t <- beta.temp(bbs1980, bbs2000, index.family = "sor")

# plotting root transformed components
with(bbs.t, plot(sqrt(beta.sim) ~ sqrt(beta.sne), type = "n", 
  ylab = expression(sqrt(beta[sim])), xlab = expression(sqrt(beta[sne]))))
with(bbs.t, text(y = sqrt(beta.sim), x = sqrt(beta.sne), 
  labels = rownames(bbs1980)))
