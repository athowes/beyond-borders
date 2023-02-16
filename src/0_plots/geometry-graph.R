pdf("geometry-graph-mwi.pdf", h = 2.5, w = 6.25)

arealutils::plot_graph(mw, add_geography = TRUE)

dev.off()

pdf("geometry-graph-zwe.pdf", h = 2.5, w = 6.25)

arealutils::plot_graph(zw, add_geography = TRUE)

dev.off()
