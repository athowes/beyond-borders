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

boxplot <- function(df, metric, y_lab = NULL, remove_constant = FALSE) {

  .calc_boxplot_stat <- function(x) {
    coef <- 1.5
    n <- sum(!is.na(x))
    stats <- quantile(x, probs = c(0.0, 0.25, 0.5, 0.75, 1.0))
    names(stats) <- c("ymin", "lower", "middle", "upper", "ymax")
    iqr <- diff(stats[c(2, 4)])
    outliers <- x < (stats[2] - coef * iqr) | x > (stats[4] + coef * iqr)
    if (any(outliers)) {
      stats[c(1, 5)] <- range(c(stats[2:4], x[!outliers]), na.rm = TRUE)
    }
    return(stats)
  }

  if(remove_constant){
    df <- df %>% filter(inf_model != "Constant")
  }

  if(is.null(y_lab)) {
    y_lab <- toupper(metric)
  }

  ggplot(df, aes(x = inf_model, y = .data[[metric]])) +
    stat_summary(fun.data = .calc_boxplot_stat, geom = "boxplot", width = 0.5, alpha = 0.9, show.legend = FALSE, fill = lightgrey) +
    stat_summary(fun = "mean", geom = "point", position = position_dodge(width = 0.5), alpha = 0.7, show.legend = FALSE) +
    facet_grid(~sim_model, scales = "free") +
    labs(x = "Inferential model", y = y_lab, title = df$geometry[1], fill = "Simulation model") +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)
    )
}
