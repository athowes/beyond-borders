#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_plot_coverage")
# setwd("src/1_plot_coverage")

df <- bind_rows(
  readRDS("depends/results_iid.rds"),
  readRDS("depends/results_besag.rds"),
  readRDS("depends/results_bym2.rds"),
  readRDS("depends/results_fck.rds"),
  readRDS("depends/results_fik.rds"),
  readRDS("depends/results_ck.rds"),
  readRDS("depends/results_ik.rds")
)

df <- filter(df, stringr::str_starts(par, "rho"))

geometries <- unique(df$geometry)

histogram_ecdf_diff_plot <- function(i) {
  x <- geometries[i]

  df <- filter(df, geometry == as.character(x)) %>%
    arealutils::update_naming()

  S <- max(df$replicate) #' Number of Monte Carlo samples

  bins <- 20
  alpha <- 0.05

  ci <- qbinom(
    p = c(alpha / 2, 0.5, (1 - alpha / 2)),
    size = S,
    prob = 1 / bins
  )

  polygon_data <- data.frame(
    x = c(-0.05, 0, 1, 0, -0.05, 1.05, 1, 1.05, -0.05),
    y = c(ci[1], ci[2], ci[2], ci[2], ci[3], ci[3], ci[2], ci[1], ci[1]) / S
  )

  figA <- ggplot(df, aes(x = q)) +
    facet_grid(sim_model ~ inf_model, drop = TRUE, scales = "free") +
    geom_histogram(aes(y = (..count..) / tapply(..count..,..PANEL..,sum)[..PANEL..]), breaks = seq(0, 1, length.out = bins + 1), fill = "#009E73", col = "black", alpha = 0.9) +
    geom_polygon(data = polygon_data, aes(x = x, y = y), fill = "grey75", color = "grey50", alpha = 0.4) +
    labs(x = "", y = "", subtitle = paste0(df$geometry)) +
    scale_x_continuous(breaks = c(0, 0.5, 1), labels = c(0, 0.5, 1)) +
    theme_minimal()

  lims <- multi.utils::get_lims(n = S, alpha, K = 100)

  figB <- df %>%
    filter(!is.na(q)) %>%
    split(~ sim_model + inf_model) %>%
    lapply(function(y) {
      empirical_coverage <- purrr::map_dbl(seq(0, 1, by = 0.01), ~ multi.utils::empirical_coverage(y$q, .x))
      data.frame(nominal_coverage = seq(0, 1, by = 0.01), empirical_coverage = empirical_coverage) %>%
        mutate(
          ecdf_diff = empirical_coverage - nominal_coverage,
          ecdf_diff_lower = lims$lower / S - nominal_coverage,
          ecdf_diff_upper = lims$upper / S - nominal_coverage,
        )
    }) %>%
    purrr::map_df(~ as.data.frame(.x), .id = "indicator") %>%
    separate(indicator, c("sim_model", "inf_model")) %>%
    mutate(
      sim_model = forcats::fct_relevel(sim_model, "IID", "Besag", "IK"),
      inf_model = forcats::fct_relevel(inf_model, "IID", "Besag")
    ) %>%
    ggplot(aes(x = nominal_coverage, y = ecdf_diff)) +
    facet_grid(sim_model ~ inf_model, drop = TRUE, scales = "free") +
    geom_line(col = "#009E73") +
    geom_step(aes(x = nominal_coverage, y = ecdf_diff_upper), alpha = 0.7, col = "grey50") +
    geom_step(aes(x = nominal_coverage, y = ecdf_diff_lower), alpha = 0.7, col = "grey50") +
    geom_abline(intercept = 0, slope = 0, linetype = "dashed", col = "grey75") +
    labs(x = "", y = "ECDF difference") +
    scale_x_continuous(breaks = c(0, 0.5, 1), labels = c(0, 0.5, 1)) +
    theme_minimal()

  figA / figB

  ggsave(paste0("histogram-ecdf-diff-", x, ".png"), h = 8, w = 6.25)
}

lapply(seq_along(geometries), function(i) histogram_ecdf_diff_plot(i))
