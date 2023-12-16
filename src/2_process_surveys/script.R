#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_process_surveys")
# setwd("src/2_process_surveys")

analysis_level <- c(
  "CIV" = 1,
  "MWI" = 5,
  "TZA" = 3,
  "ZWE" = 2
)

survey_name <- c(
  "CIV" = "CIV2017PHIA",
  "MWI" = "MWI2016PHIA",
  "TZA" = "TZA2017PHIA",
  "ZWE" = "ZWE2016PHIA"
)

iso3 <- c("civ", "mwi", "tza", "zwe")

#' This function writes the survey to file as well as outputting
surveys <- lapply(iso3, function(x) {
  df <- read_csv(file = paste0("depends/", x, "_survey_hiv_indicators.csv"))
  areas <- read_sf(paste0("depends/", tolower(x), "_areas.geojson"))

  sf <- df  %>%
    mutate(iso3 = substr(area_id, 1, 3)) %>%
    filter(
      survey_id == survey_name[toupper(x)],
      indicator == "prevalence",
      age_group == "Y015_049",
      sex == "both"
    ) %>%
    right_join(
      areas %>%
        filter(area_level == analysis_level[toupper(x)]),
      by = c("area_id", "area_name")
    ) %>%
    mutate(
      y = estimate * n_eff_kish,
      n_obs = n_eff_kish,
      .after = ci_upper
    ) %>%
    st_as_sf()

  #' Set CRS to UTM, zone 35, South
  utm_crs <- st_crs("+proj=utm +zone=35 +south +datum=WGS84")
  sf <- st_transform(sf, utm_crs)

  #' Remove the islands from Malawi
  if(x == "mwi") sf <- filter(sf, !(area_name %in% c("Likoma")))

  #' Remove the islands from Tanzania
  if(x == "tza") sf <- filter(sf, !(area_name %in% c("Kaskazini Unguja", "Kusini Unguja", "Mjini Magharibi", "Kaskazini Pemba", "Kusini Pemba")))

  saveRDS(sf, paste0(tolower(survey_name[toupper(x)]), ".rds"))

  return(sf)
})

plot_survey <- function(i, tag) {
  surveys[[i]] %>%
    ggplot(aes(fill = estimate)) +
    geom_sf(colour = scales::alpha("grey", 0.25)) +
    scale_fill_viridis_c(option = "C", label = label_percent(), limits = c(0, NA)) +
    labs(fill = "", tag = tag) +
    theme_minimal() +
    theme(
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      panel.grid = element_blank(),
      strip.text = element_text(face = "bold"),
      legend.key.size = unit(1, "lines")
    )
}

figA <- plot_survey(1, tag = "A")
figB <- plot_survey(2, tag = "B")
figC <- plot_survey(3, tag = "C")
figD <- plot_survey(4, tag = "D")

figA + figB + figC + figD + plot_layout(widths = c(1, 1, 1, 1), ncol = 2)

ggsave("hiv-surveys.png", h = 4, w = 6.25)
