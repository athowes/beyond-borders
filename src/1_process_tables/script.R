#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_process_tables")
# setwd("src/1_process_tables")

df <- bind_rows(
  readRDS("depends/results_iid.rds"),
  readRDS("depends/results_besag.rds")
)

#' CRPS table
df_crps <- df %>%
  arealutils::update_naming() %>%
  group_by(geometry, sim_model, inf_model) %>%
  summarise(crps = mean(crps)) %>%
  tidyr::spread(inf_model, crps)

gt_crps <- gt(df_crps, rowname_col = "sim_model", groupname_col = "geometry") %>%
  gt::fmt_number(columns = c(-1, -2), n_sigfig = 2) %>%
  tab_spanner(
    label = "Inferential model",
    columns = everything()
  ) %>%
  tab_stubhead("Simulation model")

saveRDS(gt_crps, "gt_crps.rds")
