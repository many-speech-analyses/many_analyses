# betapart shenanigans --------------------------------------------------------


# Source libs and load simulated data -----------------------------------------

source(here::here("scripts", "r", "00_libs.R"))
sim_df <- read_csv(here("data", "sim", "simulated_df.csv"))

# -----------------------------------------------------------------------------





# Shennanigans start here

# number of observations
nobs = 1

# add some random columns
sim_df$variable1 = ""
sim_df$variable2 = ""
sim_df$variable3 = ""
sim_df$variable4 = ""
sim_df$variable5 = ""

# loop through df an fill columns
for (k in 1:nrow(sim_df)) { 
  # print progress
  print(paste0("random sample # ", k))
  
  # add variable with probability proportional to sim_df$fixed
  sim_df$variable1[k] <- rbinom(n = nobs, size = 1, prob = sim_df$fixed / 10)
  sim_df$variable2[k] <- rbinom(n = nobs, size = 1, prob = sim_df$fixed / 10)
  sim_df$variable3[k] <- rbinom(n = nobs, size = 1, prob = sim_df$fixed / 10)
  sim_df$variable4[k] <- rbinom(n = nobs, size = 1, prob = sim_df$fixed / 10)
  sim_df$variable5[k] <- rbinom(n = nobs, size = 1, prob = sim_df$fixed / 10)
  
} #endfor_k

# bring into betapart shape
df3 <- sim_df %>% 
  select(variable1,
         variable2,
         variable3,
         variable4,
         variable5) %>% 
  mutate_if(is.character, as.numeric)

# get betapart objects
df.core <- betapart.core(df3)

# get pairwise distance
df.pair <- beta.pair(df.core, index.family = "sorensen")

# which one is it? beta.sim / beta.sne / beta.sor?
# if beta.sor then

df.pair.sor <- broom::tidy(df.pair$beta.sor) %>% 
  rename(team = item1) %>% 
  mutate(team = paste0("team_",team)) %>% 
  group_by(team) %>% 
  summarise(distance_mean = mean(distance), .groups = "drop")

# NaN are based on teams without any filled columns basically, but even if I
# force fill one column, I get NaNs. Dunno
# Update: No more NaNs

# add to df2
df4 <- full_join(sim_df, df.pair.sor)









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
