graph_length_plot <- function(g) {
  nb <- sf_to_nb(g)

  nb_sf <- spdep::nb2lines(nb, coords = sp::coordinates(as(g, "Spatial"))) %>%
    as("sf") %>%
    st_set_crs(st_crs(g))

  line_sf <- nb_sf %>%
    mutate(length = round(sf::st_length(nb_sf), 2),
           geometry = sf::st_centroid(geometry))

  ggplot(g) +
    geom_sf() +
    geom_sf(data = nb_sf) +
    geom_sf_label(data = line_sf, aes(label = length)) +
    theme_minimal() +
    theme_void()
}
