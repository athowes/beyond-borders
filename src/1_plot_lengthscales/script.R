#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_plot_lengthscales")
# setwd("src/1_plot_lengthscales")

df <- bind_rows(
  readRDS("depends/results_fck.rds"),
  readRDS("depends/results_ck.rds")
)

geometry_files <- list(
  "geometry-1.rds", "geometry-2.rds", "geometry-3.rds", "geometry-4.rds", "grid.rds", "civ.rds", "tex.rds"
)

best_lengthscales <- sapply(geometry_files, function(file) {
  readRDS(paste0("depends/", file)) %>%
    centroid_distance() %>%
    arealutils::best_average()
})


df %>%
  filter(
    par == "log_l",
    !is.na(truth)
  ) %>%
  arealutils::update_naming() %>%
  ggplot(aes(x = as.factor(replicate), y = mean)) +
    geom_point(alpha = 0.5) +
    geom_errorbar(aes(ymin = lower, ymax = upper), alpha = 0.5) +
    geom_hline(aes(yintercept = truth)) +
    facet_grid(geometry ~ .) +
    coord_flip() +
    labs(x = "Replicate", y = "Lengthscale") +
    theme_minimal()

ggsave("lengthscale-recovery.png", h = 7, w = 6.25, bg = "white")
