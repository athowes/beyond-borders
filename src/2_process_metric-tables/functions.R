#' Only works for LOO and SLOO metrics
metric_table <- function(df, metric, title = NULL, subtitle = NULL, latex = FALSE, scale = 1) {

  metric_mean.LOO <- paste0(metric, "_mean.LOO")
  metric_se.LOO <- paste0(metric, "_se.LOO")
  metric_mean.SLOO <- paste0(metric, "_mean.SLOO")
  metric_se.SLOO <- paste0(metric, "_se.SLOO")

  df <- df %>%
    select(geometry, inf_model,
           !!metric_mean.LOO, !!metric_se.LOO,
           !!metric_mean.SLOO, !!metric_se.SLOO) %>%
    rename(mean.LOO = !!metric_mean.LOO, se.LOO = !!metric_se.LOO,
           mean.SLOO = !!metric_mean.SLOO, se.SLOO = !!metric_se.SLOO) %>%
    mutate(mean.LOO = scale * signif(mean.LOO, 3),
           se.LOO = scale * signif(se.LOO, 3),
           mean.SLOO = scale * signif(mean.SLOO, 3),
           se.SLOO = scale * signif(se.SLOO, 3),
           val.LOO = paste0(mean.LOO, " (", se.LOO, ")"),
           val.SLOO = paste0(mean.SLOO, " (", se.SLOO, ")")) %>%
    select(-mean.LOO, -se.LOO, -mean.SLOO, -se.SLOO)

  table <- df %>%
    arrange(match(inf_model, c("Constant", "IID", "Besag", "BYM2", "FCK", "CK", "FIK", "IK"))) %>%
    arrange_at(1) %>%
    gt(rowname_col = "inf_model", groupname_col = "geometry") %>%
    tab_spanner_delim(delim = ".") %>%
    tab_style(style = cell_text(weight = "bold"), locations = cells_row_groups()) %>%
    tab_header(title = title, subtitle = subtitle) %>%
    tab_spanner(
      label = toupper(metric),
      columns = everything()
    ) %>%
    tab_stubhead("Inferential model")

  if(latex){
    return(
      table %>%
        as_latex() %>%
        as.character() %>%
        cat()
    )
  } else {
    return(table)
  }
}
