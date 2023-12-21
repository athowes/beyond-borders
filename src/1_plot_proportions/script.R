#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_plot_proportions")
# setwd("src/1_plot_proportions")

df <- readRDS("depends/results_bym2.rds")

df %>%
  filter(
    par == "logit_phi",
    !(geometry %in% c("1", "2", "3", "4")),
    replicate <= 40
  ) %>%
  arealutils::update_naming() %>%
  mutate(
    spatial_structure = case_when(
      mean > 0 ~ "Mostly Besag",
      mean <= 0 ~ "Mostly IID"
    )
  ) %>%
  ggplot(aes(x = as.factor(replicate), y = mean, col = spatial_structure)) +
    geom_point() +
    geom_errorbar(aes(ymin = lower, ymax = upper), width = 0) +
    facet_grid(sim_model ~ geometry, scales = "free") +
    scale_y_continuous(name = "BYM2 proportion log-odds", sec.axis = sec_axis(trans = ~ plogis(.), breaks = c(0.1, 0.5, 0.9), name = "")) +
    scale_color_manual(values = c("#0072B2", "#D55E00")) +
    labs(x = "Replicate", colour = "") +
    guides(col = guide_legend(override.aes = list(size = 3, alpha = 1, shape = 15, linetype = c(0, 0)))) +
    theme_minimal() +
    theme(
      axis.ticks.x = element_blank(),
      axis.text.x = element_blank(),
      panel.grid.major = element_blank(),
      legend.position = "bottom"
    )

ggsave("proportion-recovery.png", h = 7, w = 6.25, bg = "white")
