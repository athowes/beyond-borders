#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_plot_mean-se")
# setwd("src/1_plot_mean-se")

df <- bind_rows(
  readRDS("depends/results_iid.rds"),
  readRDS("depends/results_besag.rds"),
  readRDS("depends/results_bym2.rds"),
  readRDS("depends/results_fck.rds"),
  readRDS("depends/results_fik.rds"),
  readRDS("depends/results_ck.rds")
)

calc_boxplot_stat <- function(y) {
  coef <- 1.5
  n <- sum(!is.na(y))
  stats <- quantile(y, probs = c(0.0, 0.25, 0.5, 0.75, 1.0))
  names(stats) <- c("ymin", "lower", "middle", "upper", "ymax")
  iqr <- diff(stats[c(2, 4)])
  outliers <- y < (stats[2] - coef * iqr) | y > (stats[4] + coef * iqr)
  if (any(outliers)) {
    stats[c(1, 5)] <- range(c(stats[2:4], y[!outliers]), na.rm = TRUE)
  }
  return(stats)
}

cbpalette <- c("#56B4E9","#009E73", "#E69F00", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

geometry_names <- unique(df$geometry)
title <- c("1", "2", "3", "4", "Grid", "Cote d'Ivoire", "Texas")

fct_case_when <- function(...) {
  args <- as.list(match.call())
  levels <- sapply(args[-1], function(f) f[[3]])
  levels <- levels[!is.na(levels)]
  factor(dplyr::case_when(...), levels=levels)
}

lapply(seq_along(geometry_names), function(i) {
  x <- geometry_names[i]

  geometry <- readRDS(paste0("depends/", x, ".rds"))

  geometry_plot <- ggplot(geometry) +
    geom_sf() +
    theme_void()

  mean_se_plot <- df %>%
    filter(geometry == x) %>%
    filter(stringr::str_starts(par, c("rho"))) %>%
    arealutils::update_naming() %>%
    mutate(
      inf_model_type = fct_case_when(
        inf_model == "IID" ~ "Unstructured",
        inf_model %in% c("Besag", "BYM2") ~ "Adjacency",
        inf_model %in% c("FCK", "FIK", "CK", "IK") ~ "Kernel"
    )) %>%
    ggplot(aes(x = forcats::fct_rev(inf_model), y = crps, col = inf_model_type)) +
    # stat_summary(fun.data = calc_boxplot_stat, geom = "boxplot", width = 0.5, alpha = 0.9, show.legend = FALSE, fill = NA) +
    stat_summary(fun = "mean", geom = "point", position = position_dodge(width = 0.5), alpha = 0.7) +
    stat_summary(fun.data = mean_se, geom = "errorbar", fun.args = list(mult = 1.96)) +
    scale_color_manual(values = cbpalette) +
    facet_grid(sim_model ~ .) +
    labs(x = "Inferential model", y = "Continuous ranked probability score", col = "") +
    guides(col = guide_legend(override.aes = list(size = 3, alpha = 1, shape = 15, linetype = c(0, 0, 0)))) +
    coord_flip() +
    theme_minimal() +
    theme(
      legend.position = "top",
      legend.justification = "left",
      legend.direction = "vertical"
    )

  mean_se_plot + inset_element(geometry_plot, align_to = "full", left = 0.75, right = 0.95, bottom = 0.75, top = 0.95)

  ggsave(paste0("crps-mean-se-", x, ".png"), h = 5, w = 6.25, bg = "white")
})

#' Work in progress!
# df %>%
#   filter(
#     stringr::str_starts(par, c("rho")),
#     sim_model == "ik",
#     geometry %in% geometry_names[c(5, 6, 7)],
#     inf_model %in% c("iid_aghq", "besag_aghq")
#   ) %>%
#   ggplot(aes(x = forcats::fct_rev(geometry), y = crps)) +
#     stat_summary(fun = "mean", geom = "point", position = position_dodge(width = 0.5), alpha = 0.7, show.legend = FALSE) +
#     stat_summary(fun.data = mean_se, geom = "errorbar", fun.args = list(mult = 1.96)) +
#     facet_grid(inf_model ~ .) +
#     coord_flip() +
#     labs(x = "Geometry", y = "Continuous ranked probability score") +
#     theme_minimal()
