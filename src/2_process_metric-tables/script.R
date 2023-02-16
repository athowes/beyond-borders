#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_process_metric-tables")
# setwd("src/2_process_metric-tables")

manual <- readRDS("depends/manual.rds")

df <- manual %>%
  mutate(geometry = "missing", sim_model = "missing") %>%
  arealutils::update_naming() %>%
  select(-geometry, -sim_model) %>%
  group_by(survey, inf_model) %>%
  summarise(
    n = n(),
    across(mse:crps, ~ paste0(signif(mean(.x), 3), " (", signif(sd(.x) / sqrt(length(.x)), 3), ")"))
  ) %>%
  rename(MSE = mse, MAE = mae, CRPS = crps)

df %>%
  arrange(match(inf_model, c("Constant", "IID", "Besag", "BYM2", "FCK", "CK", "FIK", "IK"))) %>%
  arrange_at(1) %>%
  mutate(survey = paste0(toupper(survey), " ($n$ = ", n, ")")) %>%
  select(-n) %>%
  gt(rowname_col = "inf_model", groupname_col = "survey") %>%
  tab_style(style = cell_text(weight = "bold"), locations = cells_row_groups()) %>%
  as_latex() %>%
  as.character() %>%
  cat(file = "metric-table.txt")
