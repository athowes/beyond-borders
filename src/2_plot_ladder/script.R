#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("2_plot_ladder")
# setwd("src/2_plot_ladder")

ic <- readRDS("depends/ic_iid.rds")

lapply(ic, function(x) {

  if(is.null(x$result)) return(NULL)

  ggplot(x$result, aes(x = forcats::fct_reorder(area_name, mean), y = mean, ymin = lower, ymax = upper)) +
    geom_pointrange(position = position_dodge(width = 0.6), alpha = 0.8) +
    coord_flip() +
    theme_minimal() +
    scale_y_continuous(labels = scales::percent) +
    labs(x = "Area name", y = "Prevalence estimate")

  ggsave(paste0("ladder-", tolower(x$result$survey_id[1]), ".png"), h = 8, w = 6.25, bg = "white")
})
