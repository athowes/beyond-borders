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
    geom_point(col = "#D55E00") +
    geom_errorbar(aes(ymin = lower, ymax = upper), width = 0, col = "#D55E00") +
    facet_grid(sim_model ~ geometry, scales = "free") +
    scale_y_continuous(name = "BYM2 proportion log-odds", sec.axis = sec_axis(trans = ~ plogis(.), breaks = c(0.1, 0.5, 0.9), name = "")) +
    labs(x = "Replicate") +
    theme_minimal()

ggsave("proportion-recovery.png", h = 7, w = 6.25, bg = "white")
