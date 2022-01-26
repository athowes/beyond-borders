#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("process_hiv-surveys")
# setwd("src/process_hiv-surveys")

analysis_level <- c(
  "CIV" = 2,
  "MWI" = 5,
  "TZA" = 3,
  "ZWE" = 2
)

survey_name <- c(
  "CIV" = "CIV2012DHS",
  "MWI" = "MWI2015DHS",
  "TZA" = "TZA2012AIS",
  "ZWE" = "ZWE2015DHS"
)

iso3 <- c("civ", "mwi", "tza", "zwe")
lapply(iso3, extract_survey)
