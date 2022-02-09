#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("draw_sf-geometries")
# setwd("src/draw_sf-geometries")

#' Geometry (i)
area1 <- matrix(c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0), ncol = 2, byrow = TRUE)
area2 <- area1
area2[, 1] <- area2[, 1] + 1
area3 <- area1
area3[, 1] <- area3[, 1] + 2
geometry_i <- st_polygon(list(area1, area2, area3))

pdf("geometry-i.pdf", h = 4, w = 6.25)

ggplot() +
  geom_sf(data = geometry_i) +
  labs(title = "(i)") +
  theme_void()

dev.off()

saveRDS(geometry_i, "geometry-i.rds")

#' Geometry (ii)
geometry_ii <- NULL
saveRDS(geometry_ii, "geometry-ii.rds")

#' Geometry (iii)
geometry_iii <- NULL
saveRDS(geometry_iii, "geometry-iii.rds")

#' Geometry (iv)
geometry_iv <- NULL
saveRDS(geometry_iv, "geometry-iv.rds")
