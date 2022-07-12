#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("plot_geometry-graph")
# setwd("src/plot_geometry-graph")

pdf("geometry-graph-mwi.pdf", h = 2.5, w = 6.25)

bsae::plot_graph(mw, add_geography = TRUE)

dev.off()

pdf("geometry-graph-zwe.pdf", h = 2.5, w = 6.25)

bsae::plot_graph(zw, add_geography = TRUE)

dev.off()
