#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("plot_lengthscale-recovery")
# setwd("src/plot_lengthscale-recovery")

df_lengthscale <- readRDS("depends/df_lengthscale.rds")

best_lengthscale <- c(
  "Grid" = calc_best_average("grid.rds"),
  "Cote d'Ivoire" = calc_best_average("civ.rds"),
  "Texas" = calc_best_average("tex.rds"),
  "1" = calc_best_average("geometry-1.rds"),
  "2" = calc_best_average("geometry-2.rds"),
  "3" = calc_best_average("geometry-3.rds"),
  "4" = calc_best_average("geometry-4.rds")
)

lengthscale_mean <- df_lengthscale %>%
  group_by(inf_model, geometry) %>%
  summarise(overall_mean = mean(mean))

cbpalette <- multi.utils::cbpalette()

pdf("lengthscale-recovery.pdf", h = 4, w = 6.25)

df_lengthscale %>%
  left_join(
    lengthscale_mean,
    by = c("inf_model", "geometry")
  ) %>%
  arealutils::update_naming() %>%
  split(.$geometry) %>%
  lapply(function(x) {
    x_max <- max(as.numeric(x$replicate))
    obs <- mean(x$obs)
    overall_mean <- mean(x$overall_mean)
    best <- best_lengthscale[x$geometry[1]]

    x %>%
      select(replicate, obs, mean, upper, lower, overall_mean) %>%
      ggplot(aes(x = replicate, y = mean)) +
      geom_point(alpha = 0.5) +
      geom_errorbar(aes(ymin = lower, ymax = upper), alpha = 0.5) +
      geom_hline(yintercept = obs, col = cbpalette[1], size = 1, alpha = 0.7) +
      annotate("text", label = "Truth", col = cbpalette[1], x = x_max + 1.75, y = obs + 0.1, hjust = 0) +
      geom_hline(yintercept = overall_mean, col = cbpalette[2], size = 1, alpha = 0.7) +
      annotate("text", label = "Mean", col = cbpalette[2], x = x_max + 1.75, y = overall_mean + 0.1, hjust = 0) +
      geom_hline(yintercept = best, col = cbpalette[3], size = 1, alpha = 0.7) +
      annotate("text", label = "Heuristic", col = cbpalette[3], x = x_max + 1.75, y = best + 0.1, hjust = 0) +
      labs(title = paste0(x$inf_model[1], ": ", x$geometry[1]), x = "Simulation number", y = "Lengthscale") +
      coord_cartesian(clip = "off") +
      theme_minimal() +
      theme(
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        plot.margin = unit(c(0.5, 4, 0.5, 0.5), "lines")
      )
  })

dev.off()
