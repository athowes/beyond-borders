#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("0_tikz_besag")
# setwd("src/0_tikz_besag")

tools::texi2dvi("besag.tex", pdf = TRUE, clean = TRUE)
knitr::plot_crop("besag.pdf")

system(paste0(
  "convert -density ", 600, " besag.pdf -scene 1 -background white",
  " -alpha remove -alpha off -quality 100 besag.png"
))
