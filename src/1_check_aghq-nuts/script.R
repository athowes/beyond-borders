#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_check_aghq-nuts")
# setwd("src/1_check_aghq-nuts")

#' Check that aghq and tmbstan produce similar answers

data <- readRDS("depends/data_iid_grid.rds")
sf <- data[[1]]$sf

plot_mean_sd <- function(fit_aghq, fit_nuts, subtitle) {
  aghq_summary <- summary(fit_aghq, max_print = 100, M = 2500)

  aghq_mean_sd <- aghq_summary$randomeffectsummary %>%
    group_by(variable) %>%
    mutate(
      count_before = cumsum(row_number() >= match(variable, variable)),
      append = max(count_before) > 1,
      variable = ifelse(append, paste0(variable, "[", count_before, "]"), variable)
    ) %>%
    ungroup() %>%
    select(mean, sd, variable) %>%
    mutate(method = "AGHQ")

  nuts_mean_sd <- summary(fit_nuts)$summary %>%
    as.data.frame() %>%
    tibble::rownames_to_column("variable") %>%
    select(mean, sd, variable) %>%
    mutate(method = "NUTS")

  df <- bind_rows(aghq_mean_sd, nuts_mean_sd) %>%
    pivot_longer(cols = c("mean", "sd"), names_to = "type", values_to = "value") %>%
    pivot_wider(names_from = "method", values_from = "value") %>%
    filter(!is.na(AGHQ), !is.na(NUTS)) %>%
    mutate(
      diff = NUTS - AGHQ,
      diff_pct = diff / (NUTS),
      type = forcats::fct_recode(type, "Mean" = "mean", "SD" = "sd")
    )

  ggplot(df, aes(x = AGHQ, y = diff_pct)) +
    geom_point(alpha = 0.5, shape = 1) +
    facet_wrap(~ type, scales = "free_x") +
    scale_y_continuous(labels = scales::percent) +
    labs(x = "AGHQ estimate", y = "Percentage error against NUTS", subtitle = subtitle) +
    theme_minimal()
}

#' IID
fit_aghq <- arealutils::iid_aghq(sf, k = 3)
fit_nuts <- arealutils::iid_tmbstan(sf, nsim_warm = 500, nsim_iter = 1000, chains = 4)
plot_mean_sd(fit_aghq, fit_nuts, "IID model")
ggsave("iid-aghq-nuts.png", h = 3.5, w = 6.25)

#' Besag
fit_aghq <- arealutils::besag_aghq(sf, k = 3)
fit_nuts <- arealutils::besag_tmbstan(sf, nsim_warm = 500, nsim_iter = 1000, chains = 4)
plot_mean_sd(fit_aghq, fit_nuts, "Besag model")
ggsave("besag-aghq-nuts.png", h = 3.5, w = 6.25)

#' BYM2
fit_aghq <- arealutils::bym2_aghq(sf, k = 3)
fit_nuts <- arealutils::bym2_tmbstan(sf, nsim_warm = 500, nsim_iter = 1000, chains = 4)
plot_mean_sd(fit_aghq, fit_nuts, "BYM2 model")
ggsave("bym2-aghq-nuts.png", h = 3.5, w = 6.25)
