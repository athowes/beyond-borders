lengthscale_plot <- function(df, inf_model, geometry, best = NA, subtitle = NA) {

  overall_mean <- df %>%
    filter(sim_model == "IK", inf_model == !!inf_model, geometry == !!geometry) %>%
    summarise(overall_mean = mean(mean)) %>%
    as.numeric()

  df %>%
    filter(sim_model == "IK", inf_model == !!inf_model, geometry == !!geometry) %>%
    select(mean, upper, lower) %>%
    tibble::rownames_to_column(var = "id") %>%
    ggplot(aes(x = id, y = mean)) +
    geom_point(alpha = 0.5) +
    geom_errorbar(aes(ymin = lower, ymax = upper), alpha = 0.5) +
    geom_hline(yintercept = 2.5, col = lightblue, size = 1.5) +
    geom_hline(yintercept = overall_mean, col = lightgreen, size = 1.5) +
    geom_hline(yintercept = best, col = "#E69F00", size = 1.5) +
    labs(x = "Simulation number", y = "Lengthscale", subtitle = subtitle) +
    theme_minimal() +
    theme(
      axis.text.x=element_blank(),
      axis.ticks.x=element_blank()
    )
}
