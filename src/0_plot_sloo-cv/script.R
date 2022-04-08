#' Uncomment and run the two line below to resume development of this script
# orderly::orderly_develop_start("0_plot_sloo-cv")
# setwd("src/0_plot_sloo-cv")

sf_lightgrey <- "#E6E6E6"
lightblue <- "#56B4E9"
lightgreen <- "#009E73"

training_sets <- create_folds(zw, type = "SLOO")

df <- training_sets[[2]]$data %>%
  mutate(left_out = as.numeric(is.na(y)))

df$left_out[training_sets[[2]]$predict_on] <- 2

pdf("sloo-cv.pdf", h = 2.5, w = 6.25)

plot <- ggplot(df, aes(fill = as.factor(left_out))) +
  geom_sf(aes(geometry = geometry)) +
  coord_sf() +
  theme_minimal() +
  scale_fill_manual(
    values = c(sf_lightgrey, lightblue, lightgreen),
    name = "",
    labels = c("Fit model to", "Left out", "Predicted on")
  ) +
  theme_void() +
  theme(
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 9)
  )

plot

dev.off()

ggsave(
  "sloo-cv.png",
  plot,
  h = 2.5, w = 6.25, dpi = 300
)
