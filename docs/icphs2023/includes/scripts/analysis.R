
library(tidyverse)


cars_plot <- mtcars %>% 
  ggplot(., aes(x = drat, y = mpg)) + 
    geom_point() + 
    geom_smooth(method = lm, formula = "y ~ x") + 
    theme_test(base_size = 11, base_family = "Times")
