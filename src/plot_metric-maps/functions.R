group_mean_and_se <- function(df, group_variables) {
  df %>%
    select(-c(obs, mean, mode, lower, upper)) %>%
    group_by(.dots = lapply(group_variables, as.symbol)) %>%
    summarise(n = n(), across(mse:lds, list(mean = mean, se = ~ sd(.x) / sqrt(length(.x)))))
}

metric_map <- function(df, metric, sf, remove_constant = FALSE) {
  metric_mean <- paste0(metric, "_mean")

  if(remove_constant){
    df <- df %>% filter(inf_model != "Constant")
  }

  n_infsim <- nrow(unique(df[, c("inf_model", "sim_model")]))

  plot <- df %>%
    cbind(rep(sf$geometry, n_infsim)) %>%
    st_as_sf() %>%
    ggplot(aes(fill = .data[[metric_mean]])) +
    facet_grid(sim_model ~ inf_model) +
    geom_sf() +
    scale_fill_viridis_c(option = "C") +
    labs(fill = toupper(metric)) +
    scale_y_continuous(sec.axis = sec_axis(~ . , name = "SECOND Y AXIS", breaks = NULL, labels = NULL)) +
    scale_x_continuous(sec.axis = sec_axis(~ . , name = "SECOND X AXIS", breaks = NULL, labels = NULL)) +
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

  z <- ggplotGrob(plot)

  labelR = "Simulation model"
  labelT = "Inferential model"

  posR <- subset(z$layout, grepl("strip-r", name), select = t:r)
  posT <- subset(z$layout, grepl("strip-t", name), select = t:r)

  width <- z$widths[max(posR$r)]
  height <- z$heights[min(posT$t)]

  z <- gtable_add_cols(z, width, max(posR$r))
  z <- gtable_add_rows(z, height, min(posT$t) - 1)

  stripR <- grid::gTree(name = "Strip_right", children = grid::gList(
    grid::rectGrob(gp = grid::gpar(col = NA, fill = NA)),
    grid::textGrob(labelR, rot = -90, gp = grid::gpar(fontsize = 8.8, col = "black"))
  ))

  stripT <- grid::gTree(name = "Strip_top", children = grid::gList(
    grid::rectGrob(gp = grid::gpar(col = NA, fill = NA)),
    grid::textGrob(labelT, gp = grid::gpar(fontsize = 8.8, col = "black"))
  ))

  z <- gtable::gtable_add_grob(z, stripR, t = min(posR$t) + 1, l = max(posR$r) + 1, b = max(posR$b) + 1, name = "strip-right")
  z <- gtable::gtable_add_grob(z, stripT, t = min(posT$t), l = min(posT$l), r = max(posT$r), name = "strip-top")

  z <- gtable::gtable_add_cols(z, unit(1/5, "line"), max(posR$r))
  z <- gtable::gtable_add_rows(z, unit(1/5, "line"), min(posT$t))

  ggplotify::as.ggplot(z)
}

produce_maps <- function(arg1, arg2, arg3) {
  df_rho %>%
    filter(geometry == arg1) %>%
    bsae::update_naming() %>%
    group_mean_and_se(c("geometry", "sim_model", "inf_model", "id")) %>%
    metric_map(metric = arg3, sf = arg2) %>%
    ggsave(filename = paste0(arg3, "-map-rho-", tolower(arg1), ".pdf"), width = 6.25, height = 4)

  df_rho %>%
    filter(geometry == arg1) %>%
    filter(inf_model != "constant_inla") %>%
    bsae::update_naming() %>%
    group_mean_and_se(c("geometry", "sim_model", "inf_model", "id")) %>%
    metric_map(metric = arg3, sf = arg2) %>%
    ggsave(filename = paste0(arg3, "-map-rho-", tolower(arg1), "-no-constant.pdf"), width = 6.25, height = 4)
}
