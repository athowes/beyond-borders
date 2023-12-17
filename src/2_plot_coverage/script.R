#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_plot_coverage")
# setwd("src/2_plot_coverage")

discard_fails <- function(x) {
  lapply(x, function(y) y$result)
}

df <- bind_rows(
  discard_fails(readRDS("depends/cv_iid.rds")),
  discard_fails(readRDS("depends/cv_besag.rds")),
  discard_fails(readRDS("depends/cv_bym2.rds")),
  discard_fails(readRDS("depends/cv_fck.rds")),
  discard_fails(readRDS("depends/cv_fik.rds")),
  discard_fails(readRDS("depends/cv_ck.rds")),
  discard_fails(readRDS("depends/cv_ik.rds"))
)

survey_names <- unique(df$survey)

subtitle <- c(
  "Côte d’Ivoire, PHIA 2017",
  "Malawi, PHIA 2016",
  "Tanzania, PHIA 2017",
  "Zimbabwe, PHIA 2016"
)

lapply(seq_along(survey_names), function(i) {
  x <- survey_names[i]

  df <- df %>%
    filter(survey == as.character(x)) %>%
    mutate(
      type = toupper(type),
      inf_model = recode_factor(
        inf_model,
        "constant_aghq" = "Constant",
        "iid_aghq" = "IID",
        "besag_aghq" = "Besag",
        "bym2_aghq" = "BYM2",
        "fck_aghq" = "FCK",
        "fik_aghq" = "FIK",
        "ck_aghq" = "CK",
        "ik_aghq" = "IK"
      )
    )

  S <- max(df$index) #' Number of Monte Carlo samples

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
    facet_grid(type ~ inf_model, drop = TRUE, scales = "free") +
    geom_histogram(aes(y = (..count..) / tapply(..count..,..PANEL..,sum)[..PANEL..]), breaks = seq(0, 1, length.out = bins + 1), fill = "#009E73", col = "black", alpha = 0.9) +
    geom_polygon(data = polygon_data, aes(x = x, y = y), fill = "grey75", color = "grey50", alpha = 0.4) +
    labs(x = "", y = "", subtitle = subtitle[i]) +
    scale_x_continuous(breaks = c(0, 0.5, 1), labels = c(0, 0.5, 1)) +
    theme_minimal() +
    theme(
      axis.title.x = element_blank(),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank()
    )

  lims <- multi.utils::get_lims(n = S, alpha, K = 100)

  figB <- df %>%
    filter(!is.na(q)) %>%
    split(~ inf_model + type) %>%
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
    separate(indicator, c("inf_model", "type")) %>%
    mutate(
      inf_model = forcats::fct_relevel(inf_model, "IID", "Besag", "BYM2", "FCK", "FIK", "CK", "IK"),
      type = forcats::fct_relevel(type, "LOO", "SLOO")
    ) %>%
    ggplot(aes(x = nominal_coverage, y = ecdf_diff)) +
    facet_grid(type ~ inf_model, drop = TRUE, scales = "free") +
    geom_line(col = "#009E73") +
    geom_step(aes(x = nominal_coverage, y = ecdf_diff_upper), alpha = 0.7, col = "grey50") +
    geom_step(aes(x = nominal_coverage, y = ecdf_diff_lower), alpha = 0.7, col = "grey50") +
    geom_abline(intercept = 0, slope = 0, linetype = "dashed", col = "grey75") +
    labs(x = "", y = "ECDF difference") +
    scale_x_continuous(breaks = c(0, 0.5, 1), labels = c(0, 0.5, 1)) +
    theme_minimal() +
    theme(
      strip.text.x = element_blank()
    )

  figA / figB

  ggsave(paste0("histogram-ecdf-diff-", x, ".png"), h = 5, w = 6.25)
})
