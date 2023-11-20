#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_plot_maps")
# setwd("src/1_plot_maps")

df <- bind_rows(
  readRDS("depends/results_iid.rds"),
  readRDS("depends/results_besag.rds"),
  readRDS("depends/results_bym2.rds"),
  readRDS("depends/results_fck.rds"),
  readRDS("depends/results_fik.rds"),
  readRDS("depends/results_ck.rds")
)

geometries <- list(
  readRDS("depends/geometry-1.rds"),
  readRDS("depends/geometry-2.rds"),
  readRDS("depends/geometry-3.rds"),
  readRDS("depends/geometry-4.rds"),
  readRDS("depends/grid.rds"),
  readRDS("depends/civ.rds"),
  readRDS("depends/tex.rds")
)

geometry_names <- unique(df$geometry)

map <- function(i) {
  x <- geometry_names[i]

  map_df <- df %>%
    dplyr::filter(
      stringr::str_starts(par, "u"),
      geometry == x
    ) %>%
    arealutils::update_naming() %>%
    rename(geometry_name = geometry) %>%
    group_by(sim_model, inf_model, par, geometry_name) %>%
    summarise(
      crps = mean(crps, na.rm = TRUE)
    ) %>%
    tidyr::separate(par, into = c("par", "index"), sep = 1, convert = TRUE) %>%
    left_join(
      geometries[[i]] %>%
        mutate(index = row_number()),
      by = "index"
    ) %>%
    st_as_sf()

  ggplot(map_df, aes(fill = crps)) +
    geom_sf(size = 0.1, colour = scales::alpha("grey", 0.25)) +
    scale_fill_viridis_c(option = "E") +
    facet_grid(inf_model ~ sim_model) +
    theme_minimal() +
    labs(fill = "CRPS") +
    scale_y_continuous(sec.axis = sec_axis(~ . , name = "Inferential model", breaks = NULL, labels = NULL)) +
    scale_x_continuous(sec.axis = sec_axis(~ . , name = "Simulation model", breaks = NULL, labels = NULL)) +
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

  ggsave(paste0("map-crps-", x, ".png"), h = 8, w = 6.25, bg = "white")
}

lapply(seq_along(geometry_names), function(i) map(i))
