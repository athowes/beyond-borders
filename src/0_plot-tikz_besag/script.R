#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("0_plot-tikz_besag")
# setwd("src/0_plot-tikz_besag")

tools::texi2dvi("besag.tex", pdf = TRUE, clean = TRUE)
knitr::plot_crop("besag.pdf")
