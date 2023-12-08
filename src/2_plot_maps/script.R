#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_plot_maps")
# setwd("src/plot_maps")

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

survey_names <- unique(df$survey)

lapply(seq_along(survey_names), function(i) {
  x <- survey_names[i]

  sf <- readRDS(paste0("depends/", x, ".rds"))

  df %>%
    filter(survey == x) %>%
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
      )
    ) %>%
    left_join(
      sf %>%
        tibble::rowid_to_column("index") %>%
        select(index, geometry),
      by = "index"
    ) %>%
    st_as_sf() %>%
    ggplot(aes(fill = log(crps))) +
    geom_sf(size = 0.1, colour = scales::alpha("grey", 0.25)) +
    scale_fill_viridis_c(option = "E") +
    facet_wrap(~ inf_model) +
    theme_minimal() +
    labs(fill = "log(CRPS)") +
    theme(
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      legend.position = "bottom",
      legend.key.width = unit(4, "lines")
    )

  ggsave(paste0("map-", x, ".png"), h = 6.5, w = 6.25, bg = "white")
})
