#' Values of the length-scale recovered by the best_average() function, without any data
calc_best_average <- function(file) {
  readRDS(paste0("depends/", file)) %>%
    centroid_distance() %>%
    arealutils::best_average()
}

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
    theme(axis.text.x=element_blank(),
          axis.ticks.x=element_blank())
}
