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

lapply(seq_along(geometry_names), function(i) {
  x <- geometry_names[i]
  title <- c("1", "2", "3", "4", "Grid", "Cote d'Ivoire", "Texas")[i]

  df %>%
    filter(geometry == x) %>%
    filter(stringr::str_starts(par, c("rho"))) %>%
    arealutils::update_naming() %>%
    ggplot(aes(x = forcats::fct_rev(inf_model), y = crps, col = inf_model)) +
    # stat_summary(fun.data = calc_boxplot_stat, geom = "boxplot", width = 0.5, alpha = 0.9, show.legend = FALSE, fill = NA) +
    stat_summary(fun = "mean", geom = "point", position = position_dodge(width = 0.5), alpha = 0.7, show.legend = FALSE) +
    stat_summary(fun.data = mean_se, geom = "errorbar", fun.args = list(mult = 1.96)) +
    scale_color_manual(values = cbpalette) +
    facet_grid(sim_model ~ .) +
    guides(col = "none") +
    theme_minimal() +
    labs(x = "Inferential model", y = "Continuous ranked probability score", subtitle = title) +
    coord_flip()

  ggsave(paste0("crps-mean-se-", x, ".png"), h = 5, w = 6.25, bg = "white")
})
