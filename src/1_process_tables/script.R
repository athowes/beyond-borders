#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_process_tables")
# setwd("src/1_process_tables")

df <- bind_rows(
  readRDS("depends/results_iid.rds"),
  readRDS("depends/results_besag.rds"),
  readRDS("depends/results_bym2.rds"),
  readRDS("depends/results_fck.rds"),
  readRDS("depends/results_fik.rds"),
  readRDS("depends/results_ck.rds"),
  readRDS("depends/results_ik.rds")
)

#' CRPS table
df_crps <- df %>%
  filter(stringr::str_starts(par, c("rho"))) %>%
  arealutils::update_naming() %>%
  group_by(geometry, sim_model, inf_model) %>%
  filter(!is.na(crps)) %>%
  summarise(
    mean = mean(crps),
    se = sd(crps) / n()
  )

gt_crps <- df_crps %>%
  mutate(mean = 1000 * mean, se = 1000 * se) %>%
  mutate(value = signif(mean, digits = 3)) %>%
  select(geometry, sim_model, inf_model, value) %>%
  spread(inf_model, value) %>%
  gt(rowname_col = "sim_model", groupname_col = "geometry") %>%
  tab_spanner(
    label = "Inferential model",
    columns = everything()
  ) %>%
  tab_stubhead("Simulation model") %>%
  sub_missing(missing_text = "-")

saveRDS(gt_crps, "gt_crps.rds")

#' MSE table
df_mse <- df %>%
  filter(stringr::str_starts(par, c("rho"))) %>%
  arealutils::update_naming() %>%
  group_by(geometry, sim_model, inf_model) %>%
  filter(!is.na(mse)) %>%
  summarise(
    mean = mean(mse),
    se = sd(mse) / n()
  )

gt_mse <- df_mse %>%
  mutate(mean = 1000 * mean, se = 1000 * se) %>%
  mutate(value = signif(mean, digits = 3)) %>%
  select(geometry, sim_model, inf_model, value) %>%
  spread(inf_model, value) %>%
  gt(rowname_col = "sim_model", groupname_col = "geometry") %>%
  tab_spanner(
    label = "Inferential model",
    columns = everything()
  ) %>%
  tab_stubhead("Simulation model") %>%
  sub_missing(missing_text = "-")

saveRDS(gt_mse, "gt_mse.rds")
