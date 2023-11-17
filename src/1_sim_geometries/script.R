#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("1_sim_geometries")
# setwd("src/1_sim_geometries")

#' Parameter settings
L <- 100
l <- 2.5

#' Geometry 1

area1 <- matrix(c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0), ncol = 2, byrow = TRUE)
area2 <- area1
area2[, 1] <- area2[, 1] + 1
area3 <- area1
area3[, 1] <- area3[, 1] + 2
geometry_1 <- lapply(list(area1, area2, area3), function(area) list(area) %>% sf::st_polygon()) %>%
  sf::st_sfc() %>%
  sf::st_sf()

saveRDS(geometry_1, "geometry-1.rds")

data <- sim_iid(geometry_1, nsim)
saveRDS(data, "data_iid_1.rds")

data <- sim_icar(geometry_1, nsim)
saveRDS(data, "data_icar_1.rds")

data <- sim_ik(geometry_1, L = L, nsim, l = l)
saveRDS(data, "data_ik_1.rds")

#' Geometry 2

p <- st_point(c(0, 0))
radius1 <- st_buffer(p, dist = 1)
radius2 <- st_buffer(p, dist = 2)
radius3 <- st_buffer(p, dist = 3)
area1 <- radius1
area2 <- st_difference(radius2, radius1)
area3 <- st_difference(radius3, radius2)
geometry_2 <- lapply(list(area1, area2, area3), function(area) list(area) %>% sf::st_multipolygon()) %>%
  sf::st_sfc() %>%
  sf::st_sf()

saveRDS(geometry_2, "geometry-2.rds")

data <- sim_iid(geometry_2, nsim)
saveRDS(data, "data_iid_2.rds")

data <- sim_icar(geometry_2, nsim)
saveRDS(data, "data_icar_2.rds")

data <- sim_ik(geometry_2, L = L, nsim, l = l)
saveRDS(data, "data_ik_2.rds")

#' Geometry 3

area1 <- matrix(c(0, -0.5, 0, 0.5, 1, 1, 1, -1, 0, -0.5), ncol = 2, byrow = TRUE)
area2 <- matrix(c(1, -1, 1, 1, 2, 1.5, 2, -1.5, 1, -1), ncol = 2, byrow = TRUE)
area3 <- matrix(c(2, -1.5, 2, 1.5, 3, 2, 3, -2, 2, -1.5), ncol = 2, byrow = TRUE)
geometry_3 <- lapply(list(area1, area2, area3), function(area) list(area) %>% sf::st_polygon()) %>%
  sf::st_sfc() %>%
  sf::st_sf()

saveRDS(geometry_3, "geometry-3.rds")

data <- sim_iid(geometry_3, nsim)
saveRDS(data, "data_iid_3.rds")

data <- sim_icar(geometry_3, nsim)
saveRDS(data, "data_icar_3.rds")

data <- sim_ik(geometry_3, L = L, nsim, l = l)
saveRDS(data, "data_ik_3.rds")

#' Geometry 4

area1 <- matrix(c(0, 0, 0.5, 0, 0.5, 1, 0, 1, 0, 0), ncol = 2, byrow = TRUE)
area2 <- matrix(c(0.5, 0, 1.5, 0, 1.5, 1, 0.5, 1, 0.5, 0), ncol = 2, byrow = TRUE)
area3 <- matrix(c(1.5, 0, 3, 0, 3, 1, 1.5, 1, 1.5, 0), ncol = 2, byrow = TRUE)
geometry_4 <- lapply(list(area1, area2, area3), function(area) list(area) %>% sf::st_polygon()) %>%
  sf::st_sfc() %>%
  sf::st_sf()

saveRDS(geometry_4, "geometry-4.rds")

data <- sim_iid(geometry_4, nsim)
saveRDS(data, "data_iid_4.rds")

data <- sim_icar(geometry_4, nsim)
saveRDS(data, "data_icar_4.rds")

data <- sim_ik(geometry_4, L = L, nsim, l = l)
saveRDS(data, "data_ik_4.rds")

#' Grid

#' Create grid geometry
geometry <- create_sf_grid(height = 6, width = 6)
grid <- sf::st_sf(geometry)

saveRDS(grid, "grid.rds")

data <- sim_iid(grid, nsim)
saveRDS(data, "data_iid_grid.rds")

data <- sim_icar(grid, nsim)
saveRDS(data, "data_icar_grid.rds")

data <- sim_ik(grid, L = L, nsim, l = l)
saveRDS(data, "data_ik_grid.rds")

#' Cote d'Ivoire

#' Create Cote d'Ivoire geometry
civ <- read_sf("depends/civ_areas.geojson") %>%
  filter(area_level == 1) %>%
  select(geometry)

sf::st_crs(civ) <- NA

saveRDS(civ, "civ.rds")

data <- sim_iid(civ, nsim)
saveRDS(data, "data_iid_civ.rds")

data <- sim_icar(civ, nsim)
saveRDS(data, "data_icar_civ.rds")

data <- sim_ik(civ, L = L, nsim, l = l)
saveRDS(data, "data_ik_civ.rds")

#' Texas

#' Create geometry
#' Texas data from https://gis-txdot.opendata.arcgis.com/datasets/texas-us-house-districts
#' Download > Shapefile > Unzip to texas/ folder
geometry <- sf::st_geometry(sf::st_read("texas/U_S__House_District.shp"))
tex <- sf::st_sf(geometry)
sf::st_crs(tex) <- NA

saveRDS(tex, "tex.rds")

data <- sim_iid(tex, nsim)
saveRDS(data, "data_iid_tex.rds")

data <- sim_icar(tex, nsim)
saveRDS(data, "data_icar_tex.rds")

data <- sim_ik(tex, L = L, nsim, l = l)
saveRDS(data, "data_ik_tex.rds")

df <- bind_rows(
  data.frame(name = "Grid", type = "Realistic", geometry = grid),
  data.frame(name = "Cote d'Ivoire", type = "Realistic", geometry = civ),
  data.frame(name = "Texas", type = "Realistic", geometry = tex),
  data.frame(name = "Base", type = "Vignette", geometry = geometry_1),
  data.frame(name = "Circles", type = "Vignette", geometry = geometry_2),
  data.frame(name = "Triangle", type = "Vignette", geometry = geometry_3),
  data.frame(name = "Widths", type = "Vignette", geometry = geometry_4),
) %>%
  sf::st_as_sf()

pdf(file = "geometries.pdf", height = 4, width = 6.25)

plots <- df %>%
  split(~name) %>%
  lapply(function(x) {
    ggplot(x) +
      geom_sf() +
      theme_minimal() +
      theme_void()
  })

top_row <- cowplot::plot_grid(plots[["Base"]],  plots[["Triangle"]], plots[["Widths"]], plots[["Circles"]], nrow = 1)
bottom_row <- cowplot::plot_grid(plots[["Grid"]], plots[["Cote d'Ivoire"]], plots[["Texas"]], nrow = 1)

cowplot::plot_grid(top_row, bottom_row, nrow = 2)

dev.off()

ggsave(
  "geometries.png",
  cowplot::plot_grid(top_row, bottom_row, nrow = 2),
  width = 6.25, height = 4, units = "in", dpi = 300
)
