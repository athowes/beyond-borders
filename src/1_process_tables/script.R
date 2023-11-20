#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_process_tables")
# setwd("src/1_process_tables")

df <- bind_rows(
  readRDS("depends/results_iid.rds"),
  readRDS("depends/results_besag.rds"),
  readRDS("depends/results_bym2.rds"),
  readRDS("depends/results_fck.rds"),
  readRDS("depends/results_fik.rds"),
  readRDS("depends/results_ck.rds")
)

#' CRPS table
df_crps <- df %>%
  filter(stringr::str_starts(par, c("u")) | par == "beta_0") %>%
  arealutils::update_naming() %>%
  group_by(geometry, sim_model, inf_model) %>%
  summarise(crps = mean(crps, na.rm = TRUE)) %>%
  tidyr::spread(inf_model, crps)

gt_crps <- gt(df_crps, rowname_col = "sim_model", groupname_col = "geometry") %>%
  gt::fmt_number(columns = c(-1, -2), n_sigfig = 2) %>%
  tab_spanner(
    label = "Inferential model",
    columns = everything()
  ) %>%
  tab_stubhead("Simulation model")

saveRDS(gt_crps, "gt_crps.rds")

#' MSE table
df_mse <- df %>%
  filter(stringr::str_starts(par, c("u")) | par == "beta_0") %>%
  arealutils::update_naming() %>%
  group_by(geometry, sim_model, inf_model) %>%
  summarise(mse = mean(mse, na.rm = TRUE)) %>%
  tidyr::spread(inf_model, mse)

gt_mse <- gt(df_mse, rowname_col = "sim_model", groupname_col = "geometry") %>%
  gt::fmt_number(columns = c(-1, -2), n_sigfig = 2) %>%
  tab_spanner(
    label = "Inferential model",
    columns = everything()
  ) %>%
  tab_stubhead("Simulation model")

saveRDS(gt_crps, "gt_mse.rds")
