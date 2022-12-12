#' Set the working directory to the project root
setwd(rprojroot::find_rstudio_root_file())

#' @param i Index of the artefacts to get
archive_to_docs <- function(report, i = 1) {
  #' Artefacts to be moved
  filenames <- yaml::read_yaml(file.path(paste0("src/", report, "/orderly.yml")))$artefacts[[i]]$data$filenames

  #' Latest version in archive
  latest <- orderly::orderly_latest(report)

  #' Copy files over
  files_from <- paste0("archive/", report, "/", latest, "/", filenames)
  files_to <- paste0("docs/", filenames)

  file.copy(from = files_from, to = files_to, overwrite = TRUE)
}

#' Names of the reports to move
archive_to_docs("docs_paper")
archive_to_docs("checks", i = 1)
archive_to_docs("checks", i = 2)
archive_to_docs("checks", i = 3)
archive_to_docs("checks", i = 4)
archive_to_docs("0_demo_areal-kernels")
archive_to_docs("0_explore_inla-spde")
archive_to_docs("0_explore_wilson-pointless")
archive_to_docs("0_explore_inla-spde")

archive_to_docs("1_plot_coverage")
archive_to_docs("1_plot_metric-boxplots")

archive_to_docs("2_checks")
archive_to_docs("2_plot_metric-maps")
archive_to_docs("2_plot_prev-ladder")
