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
      diff_pct = diff / (sign(NUTS) * pmax(0.25, abs(NUTS))),
      type = forcats::fct_recode(type, "Mean" = "mean", "SD" = "sd")
    )

  ggplot(df, aes(x = AGHQ, y = diff_pct)) +
    geom_point(alpha = 0.5, shape = 1) +
    facet_wrap(~ type, scales = "free_x") +
    scale_y_continuous(labels = scales::percent) +
    labs(x = "AGHQ estimate", y = "Percentage error against NUTS", subtitle = subtitle) +
    theme_minimal()
}

time_df <- data.frame("inf_model" = c(), "aghq" = c(), "tmbstan" = c())

get_time <- function(t) {
  as.numeric(t$toc - t$tic)
}

#' IID
tictoc::tic()
fit_aghq <- arealutils::iid_aghq(sf, k = 3)
time_aghq <- tictoc::toc()

tictoc::tic()
fit_nuts <- arealutils::iid_tmbstan(sf, nsim_warm = 500, nsim_iter = 1000, chains = 4)
time_nuts <- tictoc::toc()

plot_mean_sd(fit_aghq, fit_nuts, "IID model")
ggsave("iid-aghq-nuts.png", h = 3.5, w = 6.25)

time_df <- rbind(c("IID", get_time(time_aghq), get_time(time_nuts))) %>%
  as.data.frame()

#' Besag
tictoc::tic()
fit_aghq <- arealutils::besag_aghq(sf, k = 3)
time_aghq <- tictoc::toc()

tictoc::tic()
fit_nuts <- arealutils::besag_tmbstan(sf, nsim_warm = 500, nsim_iter = 1000, chains = 4)
time_nuts <- tictoc::toc()

plot_mean_sd(fit_aghq, fit_nuts, "Besag model")
ggsave("besag-aghq-nuts.png", h = 3.5, w = 6.25)

time_df <- rbind(time_df, c("Besag", get_time(time_aghq), get_time(time_nuts)))

#' BYM2
tictoc::tic()
fit_aghq <- arealutils::bym2_aghq(sf, k = 3)
time_aghq <- tictoc::toc()

tictoc::tic()
fit_nuts <- arealutils::bym2_tmbstan(sf, nsim_warm = 500, nsim_iter = 1000, chains = 4)
time_nuts <- tictoc::toc()

plot_mean_sd(fit_aghq, fit_nuts, "BYM2 model")
ggsave("bym2-aghq-nuts.png", h = 3.5, w = 6.25)

time_df <- rbind(time_df, c("BYM2", get_time(time_aghq), get_time(time_nuts)))

#' #' FCK
#' tictoc::tic()
#' fit_aghq <- arealutils::fck_aghq(sf, k = 3)
#' time_aghq <- tictoc::toc()
#'
#' tictoc::tic()
#' fit_nuts <- arealutils::fck_tmbstan(sf, nsim_warm = 500, nsim_iter = 1000, chains = 4)
#' time_nuts <- tictoc::toc()
#'
#' plot_mean_sd(fit_aghq, fit_nuts, "FCK model")
#' ggsave("fck-aghq-nuts.png", h = 3.5, w = 6.25)
#'
#' time_df <- rbind(time_df, c("FCK", get_time(time_aghq), get_time(time_nuts)))
#'
#' #' FIK
#' tictoc::tic()
#' fit_aghq <- arealutils::fik_aghq(sf, k = 3)
#' time_aghq <- tictoc::toc()
#'
#' tictoc::tic()
#' fit_nuts <- arealutils::fik_tmbstan(sf, nsim_warm = 500, nsim_iter = 1000, chains = 4)
#' time_nuts <- tictoc::toc()
#'
#' plot_mean_sd(fit_aghq, fit_nuts, "FIK model")
#' ggsave("fik-aghq-nuts.png", h = 3.5, w = 6.25)
#'
#' time_df <- rbind(time_df, c("FIK", get_time(time_aghq), get_time(time_nuts)))
#'
#' #' CK
#' tictoc::tic()
#' fit_aghq <- arealutils::ck_aghq(sf, k = 3)
#' time_aghq <- tictoc::toc()
#'
#' tictoc::tic()
#' fit_nuts <- arealutils::ck_tmbstan(sf, nsim_warm = 500, nsim_iter = 1000, chains = 4)
#' time_nuts <- tictoc::toc()
#'
#' plot_mean_sd(fit_aghq, fit_nuts, "CK model")
#' ggsave("ck-aghq-nuts.png", h = 3.5, w = 6.25)
#'
#' time_df <- rbind(time_df, c("CK", get_time(time_aghq), get_time(time_nuts)))

names(time_df) <- c("inf_model", "aghq", "tmbstan")
readr::write_csv(time_df, "time.csv")

time_df %>%
  pivot_longer(
    cols = c("aghq", "tmbstan"),
    names_to = "software",
    values_to = "time"
  ) %>%
  mutate(
    time = as.numeric(time),
    inf_model = forcats::fct_relevel(inf_model, "IID", "Besag", "BYM2")
  ) %>%
  ggplot(aes(x = inf_model, y = time, fill = software)) +
    geom_col(position = position_dodge(), width = 0.5) +
    scale_fill_manual(values = c("#E69F00", "#F0E442")) +
    coord_flip() +
    labs(y = "Time taken (s)", x = "Inferential model", fill = "Software") +
    theme_minimal()

ggsave("time-taken.png", h = 3, w = 6.25)
