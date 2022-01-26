extract_survey <- function(iso3) {
  df <- read_csv(file = paste0(iso3, "_survey_hiv_indicators.csv"))
  df %>%
    separate(area_id, c("iso3", "area_level"), "_") %>%
    mutate(area_level = as.numeric(area_level)) %>%
    filter(
      survey_id == survey_name[toupper(iso3)],
      indicator == "prevalence",
      age_group == "Y015_049",
      sex == "both",
      area_level == analysis_level[toupper(iso3)]
    )
  write_csv(df, file = paste0(tolower(survey_name[toupper(iso3)]), ".csv"))
}
