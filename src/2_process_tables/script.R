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
  discard_fails(readRDS("depends/cv_ck.rds"))
)

df_crps <- df %>%
  mutate(
    inf_model = recode_factor(
      inf_model,
      "constant_aghq" = "Constant",
      "iid_aghq" = "IID",
      "besag_aghq" = "Besag",
      "bym2_aghq" = "BYM2",
      "fck_aghq" = "FCK",
      "fik_aghq" = "FIK",
      "ck_aghq" = "CK",
      "ik_aghq" = "IK"
    ),
    survey = recode_factor(
      survey,
      "civ2017phia" = "Côte d’Ivoire, PHIA 2017",
      "mwi2016phia" = "Malawi, PHIA 2016",
      "tza2017phia" = "Tanzania, PHIA 2017",
      "zwe2016phia" = "Zimbabwe, PHIA 2016"
    )
  ) %>%
  group_by(inf_model, survey) %>%
  filter(!is.na(crps)) %>%
  summarise(
    mean = mean(crps),
    se = sd(crps) / n()
  )

gt_crps <- df_crps %>%
  mutate(value = paste0(10^3 * round(mean, digits = 4), " (", 10^3 * round(se, digits = 4), ")")) %>%
  select(Survey = survey, inf_model, value) %>%
  spread(inf_model, value) %>%
  gt() %>%
  tab_spanner(label = "Continuous ranked probability score (m)", columns = -Survey) %>%
  sub_missing(missing_text = "-") %>%
  cols_align(align = "left", columns = "Survey")

saveRDS(gt_crps, "gt_cv-crps.rds")
