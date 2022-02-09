sf_lightgrey <- "#E6E6E6"
lightgrey <- "#D3D3D3"

lightblue <- "#56B4E9"
lightgreen <- "#009E73"
lightpink <- "#CC79A7"
light_palette <- c(lightblue, lightgreen, lightpink)

midblue <- "#3D9BD0"
midgreen <- "#00855A"
midpink <- "#B3608E"
mid_palette <- c(midblue, midgreen, midpink)

darkblue <- "#004E83"
darkgreen <- "#00380D"
darkpink <- "#802D5B"
dark_palette <- c(darkblue, darkgreen, darkpink)

cbpalette <- c("#56B4E9", "#009E73", "#E69F00", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#999999")

group_mean_and_se <- function(df, group_variables) {
  df %>%
    select(-c(obs, mean, mode, lower, upper)) %>%
    group_by(.dots = lapply(group_variables, as.symbol)) %>%
    summarise(n = n(), across(mse:lds, list(mean = mean, se = ~ sd(.x) / sqrt(length(.x)))))
}

metric_map <- function(df_id, metric, g, sf, remove_constant = FALSE) {
  metric_mean <- paste0(metric, "_mean")

  df <- df_id %>% filter(geometry == g)

  if(remove_constant){
    df <- df %>% filter(inf_model != "Constant")
  }

  n_infsim <- nrow(unique(df[,c("inf_model", "sim_model")]))

  df %>%
    cbind(rep(sf$geometry, n_infsim)) %>%
    st_as_sf() %>%
    ggplot(aes(fill = .data[[metric_mean]])) +
    facet_grid(sim_model ~ inf_model) +
    geom_sf() +
    scale_fill_viridis_c(option = "C") +
    labs(fill = toupper(metric)) +
    theme_minimal() +
    theme(
      axis.title.x = element_blank(),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      axis.title.y = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      strip.text = element_text(face = "bold"),
      plot.title = element_text(face = "bold"),
      legend.position = "bottom",
      legend.key.width = unit(4, "lines")
    )
}
