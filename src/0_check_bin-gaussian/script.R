# orderly::orderly_develop_start("check_bin-gaussian")
# setwd("src/check_bin-gaussian")

#' Binomial of sum of Gaussians versus sum of binomial of Gaussians
#' IID latent field
#' Without aggregation:
#' `y = \sum_{i = 1}^n y_i$, $y_i \sim \text{Bin}(m, \rho_i)$, $\rho_i \sim \text{Logitnormal}(\mu, \sigma^2)`
#' With aggregation:
#' `y \sim \text{Bin}(nm, \bar \rho)$, $\bar \rho = \frac{1}{n} \sum_{i = 1}^n \rho_i$, $\rho_i \sim \text{Logitnormal}(\mu, \sigma^2)`

nsim <- 500
n <- 36

#' Low prevalence setting (disease)
result <- experiment(nsim, n, -2.5, 0.5, 30)
plot(result$rho) #' This is what the underlying latent field looks like for these settings

pdf("histogram-disease.pdf", h = 4, w = 6.25)

plot_hist(result) #' And then the difference between the truth and the aggregated approximation

dev.off()

sd(result$y)
sd(result$y_agg)
sd(result$y_agg) / sd(result$y) #' Ratio

#' Probability approximately 1/2 setting (elections)
#' As before but with different `phi_mean` settings:
result_half <- experiment(nsim, n, 0, 0.5, 30)
plot_hist(result_half$rho)

pdf("histogram-election.pdf", h = 4, w = 6.25)

hist_fun(result_half)

dev.off()

sd(result_half$y)
sd(result_half$y_agg)
sd(result_half$y_agg) / sd(result_half$y) #' Ratio

#' Conclusions, things to add:
#' * Standard deviation of aggregation tends to overestimate true standard deviation,
#' * Effect is larger in the small `\rho` setting than the large `\rho` setting
#' * Should test latent field with spatial structure e.g. ICAR latent field and so on
#' * What is the effect of varying `sd_phi`? What is the effect of varying `y_sample_size`?
