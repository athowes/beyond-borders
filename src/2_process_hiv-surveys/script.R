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

#' This function writes the survey to file as well as outputting
surveys <- lapply(iso3, extract_survey)

plot_survey <- function(i, tag) {
  surveys[[i]] %>%
    ggplot(aes(fill = estimate)) +
    geom_sf(colour = scales::alpha("grey", 0.25)) +
    scale_fill_viridis_c(option = "C", label = label_percent()) +
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

ggsave("hiv-surveys.png", h = 5, w = 6.25)
