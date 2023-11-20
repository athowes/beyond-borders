#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_plot_boxplots")
# setwd("src/1_plot_boxplots")

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

df %>%
  filter(stringr::str_starts(par, c("u")) | par == "beta_0") %>%
  arealutils::update_naming() %>%
  ggplot(aes(x = forcats::fct_rev(inf_model), y = crps, col = inf_model)) +
  stat_summary(fun.data = calc_boxplot_stat, geom = "boxplot", width = 0.5, alpha = 0.9, show.legend = FALSE, fill = NA) +
  stat_summary(fun = "mean", geom = "point", position = position_dodge(width = 0.5), alpha = 0.7, show.legend = FALSE) +
  scale_color_manual(values = cbpalette) +
  facet_grid(sim_model ~ .) +
  theme_minimal() +
  labs(x = "Inferential model", y = "CRPS") +
  coord_flip()

ggsave("crps-boxplot.png", h = 5, w = 6.25, bg = "white")

df %>%
  filter(stringr::str_starts(par, c("u")) | par == "beta_0") %>%
  arealutils::update_naming() %>%
  ggplot(aes(x = forcats::fct_rev(inf_model), y = mse, col = inf_model)) +
  stat_summary(fun.data = calc_boxplot_stat, geom = "boxplot", width = 0.5, alpha = 0.9, show.legend = FALSE, fill = NA) +
  stat_summary(fun = "mean", geom = "point", position = position_dodge(width = 0.5), alpha = 0.7, show.legend = FALSE) +
  scale_color_manual(values = cbpalette) +
  facet_grid(sim_model ~ .) +
  theme_minimal() +
  labs(x = "Inferential model", y = "MSE") +
  coord_flip()

ggsave("mse-boxplot.png", h = 5, w = 6.25, bg = "white")
