#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("draw_sf-geometries")
# setwd("src/draw_sf-geometries")

#' Geometry 1
area1 <- matrix(c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0), ncol = 2, byrow = TRUE)
area2 <- area1
area2[, 1] <- area2[, 1] + 1
area3 <- area1
area3[, 1] <- area3[, 1] + 2
geometry_1 <- st_polygon(list(area1, area2, area3))

saveRDS(geometry_1, "geometry-1.rds")

#' Geometry 2
p <- st_point(c(0, 0))
radius1 <- st_buffer(p, dist = 1)
radius2 <- st_buffer(p, dist = 2)
radius3 <- st_buffer(p, dist = 3)
area1 <- radius1
area2 <- st_difference(radius2, radius1)
area3 <- st_difference(radius3, radius2)
geometry_2 <- st_multipolygon(list(area1, area2, area3))

saveRDS(geometry_2, "geometry-2.rds")

#' Geometry 3
area1 <- matrix(c(0, -0.5, 0, 0.5, 1, 1, 1, -1, 0, -0.5), ncol = 2, byrow = TRUE)
area2 <- matrix(c(1, -1, 1, 1, 2, 1.5, 2, -1.5, 1, -1), ncol = 2, byrow = TRUE)
area3 <- matrix(c(2, -1.5, 2, 1.5, 3, 2, 3, -2, 2, -1.5), ncol = 2, byrow = TRUE)
geometry_3 <- st_polygon(list(area1, area2, area3))

saveRDS(geometry_3, "geometry-3.rds")

#' Geometry 4
area1 <- matrix(c(0, 0, 0.5, 0, 0.5, 1, 0, 1, 0, 0), ncol = 2, byrow = TRUE)
area2 <- matrix(c(0.5, 0, 1.5, 0, 1.5, 1, 0.5, 1, 0.5, 0), ncol = 2, byrow = TRUE)
area3 <- matrix(c(1.5, 0, 3, 0, 3, 1, 1.5, 1, 1.5, 0), ncol = 2, byrow = TRUE)
geometry_4 <- st_polygon(list(area1, area2, area3))

saveRDS(geometry_4, "geometry-4.rds")

pdf("geometries.pdf", h = 4, w = 6.25)

cowplot::plot_grid(
  ggplot() +
    geom_sf(data = geometry_1) +
    #labs(title = "1") +
    theme_void(),
  ggplot() +
    geom_sf(data = geometry_2) +
    #labs(title = "2") +
    theme_void(),
  ggplot() +
    geom_sf(data = geometry_3) +
    #labs(title = "3") +
    theme_void(),
  ggplot() +
    geom_sf(data = geometry_4) +
    #labs(title = "4") +
    theme_void(),
  ncol = 2
)

dev.off()
