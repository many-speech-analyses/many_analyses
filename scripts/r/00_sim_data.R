### Info # ---------------------------------------------------------------------
#
## Author:  Timo Roettger (timo.b.roettger @ gmail.com)
#
## Project: Many speech analyses
#
## Description: simulate hypothetical data for hypothesis testing analysis
#
## Version: 11/11/2020
# ------------------------------------------------------------------------------

## libraries--------------------------------------------------------------------
source(here::here("scripts", "r", "00_libs.R"))



# get path
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path))

## set parameters---------------------------------------------------------------

# number of observations
nobs = 1

# overall effect
meta_effect = 1

# probability of peer verdict
prob_peer_verdict = c(0.2, 0.6, 0.15, 0.05)

# lambda for fixed effect
fixed_lambda = 3

# lambda for random effect
random_lambda = 3

# probability of posthoc changes
post_prob = 0.2

# lambda for models run
models_lambda = 3

# number of team
nteams = 16

# number of reviewers
nrevs  = 8

# number of reviews per reviewer
nreviews  = nteams / nrevs

# random fluctuation between reviewers for rating
rand_revs = 0.5

## loop and create data frame for teams-----------------------------------------

# create empty vectors
team_c = c()
reviewer_c = c()
dv_c = c()
se_c = c()
peer_rating_c = c()
peer_verdict_c = c()
fixed_c = c()
random_c = c()
posthoc_c = c()
nmodels_c = c()


for (i in 1:nteams) { 
  # print progress
  print(paste0("random sample # ", i))
  
  team_c = c(team_c, 
             paste0("team_", i))

  ## generate parameters

  # generate effect size 
  dv_c <- c(dv_c,
            rnorm(n = nobs, mean = meta_effect, sd = 1))
  
  # generate standard error (NOTE: in our model SE is equivalent to SD which 
  # by def. must be non-negative)
  se_c <- c(se_c,
            rnorm(n = nobs, mean = 1, sd = 0.35))
  
  
  # generate predictors
  
  # number of fixed effect parameters (poisson distributed)
  fixed_c <- c(fixed_c,
               rpois(n = nobs, lambda = fixed_lambda))

  # number of random effect parameters (poisson distributed)
  random_c <- c(random_c,
                rpois(n = nobs, lambda = random_lambda))

  # post hoc changes to analysis (yes vs. no)
  posthoc_c <- c(posthoc_c,
                 rbinom(n = nobs, size = 1, prob = post_prob))

  # number of models run before converging on final model
  nmodels_c <- c(nmodels_c,
                 rpois(n = nobs, lambda = models_lambda))
 
} #endfor_i


## make data frame
df <- data.frame(team = team_c,
                 es = dv_c,
                 se = se_c,
                 fixed = fixed_c,
                 random = random_c,
                 posthoc = posthoc_c,
                 nmodels = nmodels_c
)

## add reviewer infos-----------------------------------------------------------

## create reviewers
reviewers <- paste0("rev", 
                    seq(from = 1, to = nrevs))

# split teams into reviewers
split_list <- split(df$team, reviewers)

# make data frame
split <- data.frame(split_list) %>% 
  # long format
  pivot_longer(cols = 1:ncol(data.frame(split_list)),
               names_to = "reviewer",
               values_to = "team") %>% 
  group_by(reviewer) %>% 
  # create random number that represents reviewer bias
  mutate(random_factor = rnorm(1, 0, rand_revs))

# combine data frames
df2 <- full_join(df, split)

## assign nreviews to each reviewer
for (j in 1:nrow(df2)) { 
  # print progress
  print(paste0("random sample # ", j))
  # peer review ratings (0-100)
  df2$peer_rating[j] <- rtruncnorm(nobs, a = 0, b = 100, 
                                   mean = 50 *df2$random_factor[j], 
                                   sd = 15)
  # peer verdict (ordinal)
  df2$peer_verdict[j] <- sample(x = c("reject", "major", "minor", "accept"), 
                             size = nobs, replace = TRUE,
                             # some random-ish weights
                             prob = prob_peer_verdict)
  
} #endfor_j

## store------------------------------------------------------------------------
write_csv(df2, here("data", "sim", "simulated_df.csv"))

