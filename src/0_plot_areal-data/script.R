#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("0_plot_areal-data")
# setwd("src/0_plot_areal-data")

sf_lightgrey <- "#E6E6E6"
lightgrey <- "#D3D3D3"

indicator <- c(0, 0, 1, rep(0, 25))

a <- ggplot() +
  geom_sf(data = mw, aes(fill = as.factor(indicator))) +
  labs(x = "", y = "", title = "Country: Malawi", fill = "") +
  scale_fill_manual(values = c(sf_lightgrey, lightgrey)) +
  theme_void() +
  theme(legend.position = "none")

lilongwe <- filter(mw, name_1 == "Lilongwe")
points <- st_sample(lilongwe, size = 5)

v <- points %>%
  st_union() %>%
  st_voronoi()

dat <- st_intersection(st_cast(v), st_union(lilongwe))

b <- ggplot(dat) +
  geom_sf(fill = lightgrey) +
  stat_sf_coordinates(size = 0.5) +
  labs(x = "", y = "", title = "District: Lilongwe") +
  theme_void()

pdf("areal-data.pdf", h = 2.5, w = 6.25)

cowplot::plot_grid(b, a, rel_widths = c(1.5, 1), align = "v", ncol = 2)

dev.off()
