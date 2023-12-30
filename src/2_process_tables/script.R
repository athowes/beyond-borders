#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_process_tables")
# setwd("src/2_process_tables")

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

df <- df %>%
  mutate(
    type = toupper(type),
    inf_model = recode_factor(
      inf_model,
      "constant_aghq" = "Constant",
      "iid_aghq" = "IID",
      "besag_aghq" = "Besag",
      "bym2_aghq" = "BYM2",
      "fck_aghq" = "FCK",
      "ck_aghq" = "CK",
      "fik_aghq" = "FIK",
      "ik_aghq" = "IK"
    ),
    survey = recode_factor(
      survey,
      "civ2017phia" = "Côte d’Ivoire, 2017",
      "mwi2016phia" = "Malawi, 2016",
      "tza2017phia" = "Tanzania, 2017",
      "zwe2016phia" = "Zimbabwe, 2016"
    )
  )

df_crps <- df %>%
  group_by(inf_model, type, survey) %>%
  filter(!is.na(crps)) %>%
  summarise(
    mean = mean(crps),
    se = sd(crps) / n()
  )

gt_crps <- df_crps %>%
  mutate(mean = 1000 * mean, se = 1000 * se) %>%
  # mutate(value = paste0(sprintf("%0.1f", mean), " (", sprintf("%0.1f", se), ")")) %>%
  mutate(value = sprintf("%0.1f", mean)) %>%
  select(`PHIA survey` = survey, inf_model, value) %>%
  spread(inf_model, value) %>%
  gt() %>%
  cols_align(align = "left", columns = "PHIA survey") %>%
  tab_spanner(label = "Continuous ranked probability score (units: 1/1000)", columns = -`PHIA survey`) %>%
  sub_missing(missing_text = "-") %>%
  tab_style(
    style = cell_text(align = "center"),
    locations = cells_column_labels(columns = -`PHIA survey`)
  )

saveRDS(gt_crps, "gt_cv-crps.rds")

df_mse <- df %>%
  group_by(inf_model, type, survey) %>%
  filter(!is.na(mse)) %>%
  summarise(
    mean = mean(mse),
    se = sd(mse) / n()
  )

gt_mse <- df_mse %>%
  mutate(mean = 1000 * mean, se = 1000 * se) %>%
  # mutate(value = paste0(sprintf("%0.02f", mean), " (", ifelse(round(se, 2) == 0, "<0.01", sprintf("%0.2f", se)), ")")) %>%
  mutate(value = sprintf("%0.02f", mean)) %>%
  select(`PHIA survey` = survey, inf_model, value) %>%
  spread(inf_model, value) %>%
  gt() %>%
  cols_align(align = "left", columns = "PHIA survey") %>%
  tab_spanner(label = "Mean squared error (units: 1/1000)", columns = -`PHIA survey`) %>%
  sub_missing(missing_text = "-") %>%
  tab_style(
    style = cell_text(align = "center"),
    locations = cells_column_labels(columns = -`PHIA survey`)
  )

saveRDS(gt_mse, "gt_cv-mse.rds")
