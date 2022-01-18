#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("plot_geography-graph")
# setwd("src/plot_geography-graph")

pdf("geography-graph.pdf", h = 4, w = 6.25)

bsae::plot_graph(mw, add_geography = TRUE)

dev.off()
