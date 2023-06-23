pdf("geometry-graph-mwi.pdf", h = 2.5, w = 6.25)

sf <- mw

nb <- sf_to_nb(sf)

nb_sf <- spdep::nb2lines(nb, coords = sp::coordinates(as(sf, "Spatial"))) %>%
  as("sf") %>%
  sf::st_set_crs(sf::st_crs(sf))

b <- ggplot(sf) +
  geom_sf(data = nb_sf) +
  theme_minimal() +
  labs(subtitle = "Graph") +
  theme_void()

a <- ggplot(sf) +
  geom_sf() +
  theme_minimal() +
  labs(subtitle = "Geography") +
  theme_void()

a + b

dev.off()

pdf("geometry-graph-zwe.pdf", h = 2.5, w = 6.25)

sf <- zw

nb <- sf_to_nb(sf)

nb_sf <- spdep::nb2lines(nb, coords = sp::coordinates(as(sf, "Spatial"))) %>%
  as("sf") %>%
  sf::st_set_crs(sf::st_crs(sf))

b <- ggplot(sf) +
  geom_sf(data = nb_sf) +
  theme_minimal() +
  labs(subtitle = "Graph") +
  theme_void()

a <- ggplot(sf) +
  geom_sf() +
  theme_minimal() +
  labs(subtitle = "Geography") +
  theme_void()

a + b

dev.off()
