#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("0_plot_areal-data")
# setwd("src/0_plot_areal-data")

set.seed(1)

sf_lightgrey <- "#E6E6E6"
lightgrey <- "#D3D3D3"

indicator <- c(1, rep(0, 32))

plotA <- ggplot() +
  geom_sf(data = ci, aes(fill = as.factor(indicator))) +
  labs(x = "", y = "", title = "Country: Cote d'Ivoire", fill = "") +
  scale_fill_manual(values = c(sf_lightgrey, lightgrey)) +
  theme_void() +
  theme(legend.position = "none")

abidjan <- ci[1, ]
points <- st_sample(abidjan, size = 8)

v <- points %>%
  st_union() %>%
  st_voronoi()

dat <- st_intersection(st_cast(v), st_union(abidjan))

plotB <- ggplot(dat) +
  geom_sf(fill = lightgrey) +
  stat_sf_coordinates(size = 0.5) +
  labs(x = "", y = "", title = "District: Abidjan") +
  theme_void()

pdf("areal-data.pdf", h = 2.5, w = 6.25)

plot <- cowplot::plot_grid(plotB, plotA, rel_widths = c(1.5, 1), align = "v", ncol = 2)

plot

dev.off()

ggsave(
  "areal-data.png",
  plot,
  h = 2.5, w = 6.25, dpi = 300
)
