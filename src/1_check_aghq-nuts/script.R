#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_check_aghq-nuts")
# setwd("src/1_check_aghq-nuts")

set.seed(1)

#' Check that aghq and tmbstan produce similar answers

data <- readRDS("depends/data_iid_grid.rds")
sf <- data[[2]]$sf

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
      diff_pct = diff / (sign(NUTS) * pmax(0.25, abs(NUTS))),
      type = forcats::fct_recode(type, "Posterior mean" = "mean", "Posterior SD" = "sd")
    )

  ggplot(df, aes(x = AGHQ, y = diff_pct)) +
    geom_point(alpha = 0.5, shape = 1) +
    facet_wrap(~ type, scales = "free_x") +
    geom_abline(intercept = 0, slope = 0, col = "#E69F00", linetype = "dashed") +
    scale_y_continuous(labels = scales::percent) +
    labs(x = "Estimate", y = "Percentage difference to NUTS", subtitle = subtitle) +
    theme_minimal()
}

get_time <- function(t) {
  as.numeric(t$toc - t$tic)
}

#' IID
tictoc::tic()
fit_aghq <- arealutils::iid_aghq(sf, k = 3, ii = NULL)
time_aghq <- tictoc::toc()

tictoc::tic()
fit_nuts <- arealutils::iid_tmbstan(sf, nsim_warm = 4000, nsim_iter = 8000, chains = 1, ii = NULL)
time_nuts <- tictoc::toc()

plot_mean_sd(fit_aghq, fit_nuts, "IID model")
ggsave("iid-aghq-nuts.png", h = 3.5, w = 6.25)

time_df <- rbind(c("IID", get_time(time_aghq), get_time(time_nuts))) %>% as.data.frame()
names(time_df) <- c("inf_model", "aghq", "tmbstan")

diagnostics_df <- rbind(c("IID", min(head(summary(fit_nuts)$summary[, "n_eff"], -1)), max(head(bayesplot::rhat(fit_nuts), -1)))) %>% as.data.frame()
names(diagnostics_df) <- c("inf_model", "min_ess", "max_rhat")

#' Besag
tictoc::tic()
fit_aghq <- arealutils::besag_aghq(sf, k = 3, ii = NULL)
time_aghq <- tictoc::toc()

tictoc::tic()
fit_nuts <- arealutils::besag_tmbstan(sf, nsim_warm = 4000, nsim_iter = 8000, chains = 1)
time_nuts <- tictoc::toc()

plot_mean_sd(fit_aghq, fit_nuts, "Besag model")
ggsave("besag-aghq-nuts.png", h = 3.5, w = 6.25)

time_df <- rbind(time_df, c("Besag", get_time(time_aghq), get_time(time_nuts)))
diagnostics_df <- rbind(diagnostics_df, c("Besag", min(head(summary(fit_nuts)$summary[, "n_eff"], -1)), max(head(bayesplot::rhat(fit_nuts), -1))))

#' BYM2
tictoc::tic()
fit_aghq <- arealutils::bym2_aghq(sf, k = 3, ii = NULL)
time_aghq <- tictoc::toc()

tictoc::tic()
fit_nuts <- arealutils::bym2_tmbstan(sf, nsim_warm = 4000, nsim_iter = 8000, chains = 1)
time_nuts <- tictoc::toc()

plot_mean_sd(fit_aghq, fit_nuts, "BYM2 model")
ggsave("bym2-aghq-nuts.png", h = 3.5, w = 6.25)

time_df <- rbind(time_df, c("BYM2", get_time(time_aghq), get_time(time_nuts)))
diagnostics_df <- rbind(diagnostics_df, c("BYM2", min(head(summary(fit_nuts)$summary[, "n_eff"], -1)), max(head(bayesplot::rhat(fit_nuts), -1))))

#' FCK
tictoc::tic()
fit_aghq <- arealutils::fck_aghq(sf, k = 3, ii = NULL)
time_aghq <- tictoc::toc()

tictoc::tic()
fit_nuts <- arealutils::fck_tmbstan(sf, nsim_warm = 4000, nsim_iter = 8000, chains = 1)
time_nuts <- tictoc::toc()

plot_mean_sd(fit_aghq, fit_nuts, "FCK model")
ggsave("fck-aghq-nuts.png", h = 3.5, w = 6.25)

time_df <- rbind(time_df, c("FCK", get_time(time_aghq), get_time(time_nuts)))
diagnostics_df <- rbind(diagnostics_df, c("FCK", min(head(summary(fit_nuts)$summary[, "n_eff"], -1)), max(head(bayesplot::rhat(fit_nuts), -1))))

#' FIK
tictoc::tic()
fit_aghq <- arealutils::fik_aghq(sf, k = 3, ii = NULL)
time_aghq <- tictoc::toc()

tictoc::tic()
fit_nuts <- arealutils::fik_tmbstan(sf, nsim_warm = 4000, nsim_iter = 8000, chains = 1)
time_nuts <- tictoc::toc()

plot_mean_sd(fit_aghq, fit_nuts, "FIK model")
ggsave("fik-aghq-nuts.png", h = 3.5, w = 6.25)

time_df <- rbind(time_df, c("FIK", get_time(time_aghq), get_time(time_nuts)))
diagnostics_df <- rbind(diagnostics_df, c("FIK", min(head(summary(fit_nuts)$summary[, "n_eff"], -1)), max(head(bayesplot::rhat(fit_nuts), -1))))

#' CK
tictoc::tic()
fit_aghq <- arealutils::ck_aghq(sf, k = 3, ii = NULL)
time_aghq <- tictoc::toc()

tictoc::tic()
fit_nuts <- arealutils::ck_tmbstan(sf, nsim_warm = 4000, nsim_iter = 8000, chains = 1)
time_nuts <- tictoc::toc()

plot_mean_sd(fit_aghq, fit_nuts, "CK model")
ggsave("ck-aghq-nuts.png", h = 3.5, w = 6.25)

time_df <- rbind(time_df, c("CK", get_time(time_aghq), get_time(time_nuts)))
diagnostics_df <- rbind(diagnostics_df, c("CK", min(head(summary(fit_nuts)$summary[, "n_eff"], -1)), max(head(bayesplot::rhat(fit_nuts), -1))))

#' IK
set.seed(2) # Requires avoiding certain initialisations to work...

tictoc::tic()
fit_aghq <- arealutils::ik_aghq(sf, k = 3, ii = NULL)
time_aghq <- tictoc::toc()

tictoc::tic()
fit_nuts <- arealutils::ik_tmbstan(sf, nsim_warm = 4000, nsim_iter = 8000, chains = 1)
time_nuts <- tictoc::toc()

plot_mean_sd(fit_aghq, fit_nuts, "IK model")
ggsave("ik-aghq-nuts.png", h = 3.5, w = 6.25)

time_df <- rbind(time_df, c("IK", get_time(time_aghq), get_time(time_nuts)))
diagnostics_df <- rbind(diagnostics_df, c("IK", min(head(summary(fit_nuts)$summary[, "n_eff"], -1)), max(head(bayesplot::rhat(fit_nuts), -1))))

readr::write_csv(diagnostics_df, "diagnostics.csv")
readr::write_csv(time_df, "time.csv")

time_df %>%
  pivot_longer(
    cols = c("aghq", "tmbstan"),
    names_to = "software",
    values_to = "time"
  ) %>%
  mutate(
    time = as.numeric(time),
    inf_model = forcats::fct_relevel(inf_model, "IID", "Besag", "BYM2", "FCK", "CK", "FIK")
  ) %>%
  ggplot(aes(x = forcats::fct_rev(inf_model), y = time, fill = software)) +
    geom_col(position = position_dodge(), width = 0.5) +
    scale_fill_manual(values = c("#D55E00", "#CC79A7")) +
    facet_wrap(software ~ ., scales = "free") +
    coord_flip() +
    labs(y = "Time taken (s)", x = "Inferential model", fill = "") +
    guides(fill = "none") +
    theme_minimal()

ggsave("time-taken.png", h = 3, w = 6.25)
