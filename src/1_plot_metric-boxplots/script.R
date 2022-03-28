#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("plot_metric-boxplots")
# setwd("src/plot_metric-boxplots")

df_rho <- readRDS("depends/df_rho.rds")
df_intercept <- readRDS("depends/df_intercept.rds")

#' CRPS boxplot for rho
pdf("crps-boxplot-rho.pdf", h = 8, w = 6.25)

df_rho %>%
  bsae::update_naming() %>%
  boxplot(
    metric = "crps",
    y_lab = "CRPS"
  )

dev.off()

pdf("crps-boxplot-rho-no-constant.pdf", h = 8, w = 6.25)

df_rho %>%
  filter(inf_model != "constant_inla") %>%
  bsae::update_naming() %>%
  boxplot(
    metric = "crps",
    y_lab = "CRPS"
  )

dev.off()

#' CRPS boxplot for the intercept
pdf("crps-boxplot-intercept.pdf", h = 8, w = 6.25)

df_intercept %>%
  bsae::update_naming() %>%
  boxplot(
    metric = "crps",
    y_lab = "CRPS"
  )

dev.off()

pdf("crps-boxplot-intercept-no-constant.pdf", h = 8, w = 6.25)

df_intercept %>%
  filter(inf_model != "constant_inla") %>%
  bsae::update_naming() %>%
  boxplot(
    metric = "crps",
    y_lab = "CRPS"
  )

dev.off()
