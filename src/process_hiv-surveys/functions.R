extract_survey <- function(iso3) {
  df <- read_csv(file = paste0("depends/", iso3, "_survey_hiv_indicators.csv"))
  areas <- read_sf(paste0("depends/", tolower(iso3), "_areas.geojson"))

  sf <- df  %>%
    mutate(iso3 = substr(area_id, 1, 3)) %>%
    right_join(
      areas %>%
        filter(area_level == analysis_level[toupper(iso3)]),
      by = c("area_id", "area_name")
    ) %>%
    filter(
      survey_id == survey_name[toupper(iso3)],
      indicator == "prevalence",
      age_group == "Y015_049",
      sex == "both"
    ) %>%
    mutate(
      y = estimate * n_eff_kish,
      n_obs = n_eff_kish,
      .after = ci_upper
    ) %>%
    st_as_sf() %>%
    st_transform(4326)

  st_write(sf, paste0(tolower(survey_name[toupper(iso3)]), ".geojson"))

  return(sf)
}
