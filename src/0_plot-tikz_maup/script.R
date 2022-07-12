#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("0_plot-tikz_maup")
# setwd("src/0_plot-tikz_maup")

tools::texi2dvi("maup1.tex", pdf = TRUE, clean = TRUE)
tools::texi2dvi("maup2.tex", pdf = TRUE, clean = TRUE)
tools::texi2dvi("maup3.tex", pdf = TRUE, clean = TRUE)
