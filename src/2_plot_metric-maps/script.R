#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("plot_hiv-metric-maps")
# setwd("src/plot_hiv-metric-maps")

surveys <- c("civ2017phia", "mwi2016phia", "tza2017phia", "zwe2016phia")

hiv_surveys <- lapply(surveys, function(x) {
  st_read(paste0("depends/", x, ".geojson")) %>%
    tibble::rownames_to_column("id") %>%
    mutate(id = as.numeric(id))
  }) %>%
  bind_rows() %>%
  select(survey = survey_id, id, geometry)

sf <- readRDS("depends/df.rds") %>%
  mutate(
    survey = toupper(survey),
    id = as.numeric(id),
    inf_model = recode_factor(inf_model,
      "constant_inla" = "Constant",
      "iid_inla" = "IID",
      "besag_inla" = "Besag",
      "bym2_inla" = "BYM2",
      "fck_inla" = "FCK",
      "ck_stan" = "CK",
      "fik_inla" = "FIK",
      "ik_stan" = "IK")
  ) %>%
  left_join(
    hiv_surveys,
    by = c("survey", "id")
  ) %>%
  st_as_sf()

pdf("crps-map-hiv-surveys-no-constant.pdf", h = 4, w = 6.25)

metric_map(sf, metric = "crps")

dev.off()

pdf("mse-map-hiv-surveys-no-constant.pdf", h = 4, w = 6.25)

metric_map(sf, metric = "mse")

dev.off()

pdf("mae-map-hiv-surveys-no-constant.pdf", h = 4, w = 6.25)

metric_map(sf, metric = "mae")

dev.off()
