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

pdf("crps-map-hiv-surveys.pdf", h = 8, w = 6.25)

sf %>%
  filter(inf_model != "Constant") %>%
  #' Need to find way to facet geom_sf with scales = "free"
  #' https://jayrobwilliams.com/posts/2021/05/geom-sf-facet
  filter(survey == "MWI2016PHIA") %>%
  ggplot(aes(fill = crps)) +
  geom_sf() +
  scale_fill_viridis_c(option = "C") +
  facet_grid(survey ~ inf_model) +
  theme_minimal() +
  labs(fill = "CRPS") +
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    strip.text = element_text(face = "bold"),
    plot.title = element_text(face = "bold"),
    legend.position = "bottom",
    legend.key.width = unit(4, "lines")
  )

dev.off()
