#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("plot_coverage")
# setwd("src/plot_coverage")

df <- readRDS("depends/df_rho.rds") %>%
  mutate(replicate = as.numeric(replicate)) %>%
  bsae::update_naming() %>%
  filter(inf_model != "Constant")

geometries <- unique(df$geometry)

pdf("histogram-no-constant.pdf", h = 4, w = 6.25)

lapply(geometries, function(x) {
  df <- filter(df, geometry == as.character(x))
  S <- max(df$replicate) * max(df$id) #' Number of Monte Carlo samples
  bins <- 20
  alpha <- 0.05

  ci <- qbinom(
    p = c(alpha / 2, 0.5, (1 - alpha / 2)),
    size = S,
    prob = 1 / bins
  )

  polygon_data <- data.frame(
    x = c(-0.05, 0, 1, 0, -0.05, 1.05, 1, 1.05, -0.05),
    y = c(ci[1], ci[2], ci[2], ci[2], ci[3], ci[3], ci[2], ci[1], ci[1]) / S
  )

  ggplot(df, aes(x = quantile)) +
    facet_grid(sim_model ~ inf_model, drop = TRUE, scales = "free") +
    geom_histogram(aes(y = (..count..) / tapply(..count..,..PANEL..,sum)[..PANEL..]),
                   breaks = seq(0, 1, length.out = bins + 1), fill = "#009E73", col = "black", alpha = 0.9) +
    geom_polygon(data = polygon_data, aes(x = x, y = y), fill = "grey75", color = "grey50", alpha = 0.6) +
    labs(x = "", y = "", title = paste0(x)) +
    scale_x_continuous(breaks = c(0, 0.25, 0.5, 0.75, 1), labels = c(0, 0.25, 0.5, 0.75, 1)) +
    theme_minimal()
})

dev.off()
