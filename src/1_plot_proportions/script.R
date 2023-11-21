#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_plot_proportions")
# setwd("src/1_plot_proportions")

df <- readRDS("depends/results_bym2.rds")

df %>%
  filter(
    par == "logit_phi",
    !(geometry %in% c("1", "2", "3", "4"))
  ) %>%
  arealutils::update_naming() %>%
  ggplot(aes(x = as.factor(replicate), y = mean)) +
    geom_point(alpha = 0.5) +
    geom_errorbar(aes(ymin = lower, ymax = upper), alpha = 0.5) +
    facet_grid(geometry ~ sim_model) +
    coord_flip() +
    labs(x = "Replicate", y = "Proportion log-odds") +
    theme_minimal()

ggsave("proportion-recovery.png", h = 7, w = 6.25, bg = "white")
