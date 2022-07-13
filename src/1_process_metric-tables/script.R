#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_process_metric-tables")
# setwd("src/1_process_metric-tables")

df_rho <- readRDS("depends/df_rho.rds")
df_intercept <- readRDS("depends/df_intercept.rds")
# df_time <- readRDS("depends/df_time.rds")

#' CRPS table for rho
sink("crps-table-rho.txt")

df_rho %>%
  group_mean_and_se(group_variables = c("geometry", "sim_model", "inf_model")) %>%
  bsae::update_naming() %>%
  metric_table(
    metric = "crps",
    title = "Continuous Ranked Probability Score",
    latex = TRUE,
    scale = 10^3,
    figures = 3
  )

sink()

#' CRPS table for the intercept
sink("crps-table-intercept.txt")

df_intercept %>%
  group_mean_and_se(group_variables = c("geometry", "sim_model", "inf_model")) %>%
  bsae::update_naming() %>%
  metric_table(
    metric = "crps",
    title = "Continuous Ranked Probability Score",
    latex = TRUE,
    scale = 10^3,
    figures = 3
  )

sink()

#' #' Time table
#' sink("time-table.txt")
#'
#' df_time %>%
#'   group_by(geometry, sim_model, inf_model) %>%
#'   bsae::update_naming() %>%
#'   summarise(n = n(), across(t, list(mean = mean, se = ~ sd(.x) / sqrt(length(.x))))) %>%
#'   metric_table(
#'     metric = "t",
#'     latex = FALSE
#'   )
#'
#' sink()
