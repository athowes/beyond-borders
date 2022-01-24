#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("process_metric-tables")
# setwd("src/process_metric-tables")

df_rho <- readRDS("depends/df_rho.rds")

#' CRPS table
sink("crps-table-rho.txt")

#' Some bug happening currently with latex = TRUE here (not with latex = FALSE, so nothing fundamental)

df_rho %>%
  group_mean_and_se(group_variables = c("geometry", "sim_model", "inf_model")) %>%
  update_naming() %>%
  metric_table(
    metric = "crps",
    title = "Continuous Ranked Probability Score",
    latex = TRUE,
    scale = 10^3,
    figures = 3
  )

sink()
