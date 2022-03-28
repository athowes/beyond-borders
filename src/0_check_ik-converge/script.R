# orderly::orderly_develop_start("0_check_ik-converge")
# setwd("src/0_check_ik-converge")

#' Checking the convergence of the integrated kernel as a function of number of samples per area

type <- "random"
L <- 200
grid <- readRDS("depends/grid.rds")
n <- nrow(grid)
samples <- sf::st_sample(grid, type = type, exact = TRUE, size = rep(L, n))
length(samples) # n * L
sf::st_crs(samples) <- NA

#' Add id column
samples <- st_sf(id = rep(seq_along(1:L), n), geom = samples)

sample_sets <- lapply(seq(10, L, by = 10), function(i) subset(samples, id <= i))

# Checking that the samples look OK
pdf("sample-check.pdf", h = 3, w = 6.25)

cowplot::plot_grid(
  plot_samples(sample_sets[[1]]),
  plot_samples(sample_sets[[10]]),
  plot_samples(sample_sets[[20]]),
  ncol = 3
)

dev.off()

#' Calculate the Gram matrices
covs <- lapply(sample_sets, adapted_integrated_covariance)

pdf("gram-matrices.pdf", h = 3, w = 6.25)

cowplot::plot_grid(
  plot_matrix(covs[[1]]),
  plot_matrix(covs[[10]]),
  plot_matrix(covs[[20]]),
  ncol = 3
)

dev.off()

matrix_comparison <- outer(covs, covs, Vectorize(frobenius))

pdf("matrix-comparison.pdf", h = 5, w = 6.25)

plot_matrix(matrix_comparison)

dev.off()

#' Experiment: 10, 20 and 50 points versus ground truth 300 points
L_settings <- list(10, 20, 50)
gt_samples <- sf::st_sample(grid, type = type, exact = TRUE, size = rep(300, n))
gt_cov <- adapted_integrated_covariance(gt_samples)
result <- lapply(L_settings, int_convergence_experiment)

names(result) <- c("L_10", "L_20", "L_50")

result <- list_to_df(result) %>%
  pivot_longer(
    cols = 1:3,
    names_to = "L",
    names_prefix= "L_",
    values_to = "value"
  ) %>%
  mutate(L = as.numeric(L))

pdf("shrinking-frobenius.pdf", h = 4, w = 6.25)

ggplot(result, aes(x = value)) +
  geom_histogram() +
  facet_grid(~L) +
  labs(x = "Frobenius norm", y = "") +
  theme_minimal()

dev.off()
