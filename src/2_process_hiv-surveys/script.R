#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_process_hiv-surveys")
# setwd("src/2_process_hiv-surveys")

analysis_level <- c(
  "CIV" = 1,
  "MWI" = 5,
  "TZA" = 4,
  "ZWE" = 2
)

survey_name <- c(
  "CIV" = "CIV2017PHIA",
  "MWI" = "MWI2016PHIA",
  "TZA" = "TZA2017PHIA",
  "ZWE" = "ZWE2016PHIA"
)

iso3 <- c("civ", "mwi", "tza", "zwe")

#' This function writes the survey to file as well as outputing
surveys <- lapply(iso3, extract_survey)

pdf("hiv-surveys.pdf", h = 5, w = 6.25)

lapply(surveys, function(x) {
  x %>%
    ggplot(aes(fill = estimate)) +
    geom_sf(size = 0.1, colour = scales::alpha("grey", 0.25)) +
    scale_fill_viridis_c(option = "C", label = label_percent()) +
    labs(fill = "HIV prevalence estimate", title = paste0(x$survey_id[1])) +
    theme_minimal() +
    theme(
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      panel.grid = element_blank(),
      strip.text = element_text(face = "bold"),
    )
})

dev.off()
