#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_plot_lengthscales")
# setwd("src/1_plot_lengthscales")

df <- bind_rows(
  readRDS("depends/results_fck.rds"),
  readRDS("depends/results_ck.rds")
)

unique_geometries <- unique(df$geometry)

best_lengthscales <- lapply(unique_geometries, function(geometry) {

  if(nchar(toString(geometry)) == 1) {
    geometry_name <- paste0("geometry-", geometry)
  } else {
    geometry_name <- geometry
  }

  l <- readRDS(paste0("depends/", geometry_name, ".rds")) %>%
    centroid_distance() %>%
    arealutils::best_average()

  return(list("geometry" = geometry, "l" = l))
}) %>%
  bind_rows() %>%
  mutate(geometry = recode_factor(
    geometry,
    "1" = "1",
    "2" = "2",
    "3" = "3",
    "4" = "4",
    "grid" = "Grid",
    "civ" = "Cote d'Ivoire",
    "tex" = "Texas"
  ))

df %>%
  filter(
    par == "log_l",
    !is.na(truth)
  ) %>%
  arealutils::update_naming() %>%
  ggplot(aes(x = as.factor(replicate), y = mean)) +
    geom_point(col = "#56B4E9") +
    geom_errorbar(aes(ymin = lower, ymax = upper), width = 0, col = "#56B4E9") +
    geom_hline(aes(yintercept = truth), col = "grey30") +
    geom_hline(data = best_lengthscales, aes(yintercept = l), col = "#009E73") +
    facet_wrap(. ~ geometry, scales = "free") +
    geom_col(data = data.frame(x = rep(0, 2), y = rep(0, 2), type = as.factor(c("Fixed (Best heuristic)", "Inferred"))), aes(x = x, y = y, fill = type)) +
    scale_fill_manual(values = c("#56B4E9", "#009E73")) +
    labs(x = "Replicate", y = "Log-lengthscale", fill = "") +
    theme_minimal() +
    theme(legend.position = "bottom")

ggsave("lengthscale-recovery.png", h = 4, w = 6.25, bg = "white")
