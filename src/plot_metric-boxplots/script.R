#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("plot_metric-boxplots")
# setwd("src/plot_metric-boxplots")

df_rho <- readRDS("depends/df_rho.rds")
df_intercept <- readRDS("depends/df_intercept")

#' CRPS boxplot for rho
pdf("crps-boxplot-rho.pdf", h = 4, w = 6.25)

df_rho %>%
  update_naming() %>%
  boxplot(
    metric = "crps",
    y_lab = "CRPS"
  )

dev.off()

#' CRPS boxplot for the intercept
pdf("crps-boxplot-intercept.pdf", h = 4, w = 6.25)

df_intercept %>%
  update_naming() %>%
  boxplot(
    metric = "crps",
    y_lab = "CRPS"
  )

dev.off()
