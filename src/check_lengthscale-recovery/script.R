# orderly::orderly_develop_start("check_lengthscale-recovery")
# setwd("src/check_lengthscale-recovery")

#' Simulating data from l = 1 or 3 and seeing if it can be recovered

grid <- readRDS("depends/grid.rds")

#' l = 1
ck_one <- sim_ck(grid, nsim = 10, l = 1, save = FALSE)

fits_one <- lapply(ck_one, FUN = function(x) bsae::ck_stan(x$sf))
lengthscale_summary_one <- lapply(fits_one, FUN = function(fit) summary(fit)$summary["l", ])
df_lengthscale_one <- list_to_df(lengthscale_summary_one)

pdf("1-recovery-lengthscale.pdf", h = 3, w = 6.25)

ggplot(df_lengthscale_one, aes(x = replicate, y = mean)) +
  geom_point() +
  geom_errorbar(aes(ymin = X2.5., ymax = X97.5.)) +
  geom_hline(yintercept = 1, size = 0.75, col = "grey", alpha = 0.75) +
  labs(x = "Replicate", y = "Posterior CrI", title = "Is l = 1 recovered?") +
  theme_minimal()

dev.off()

#' Ratio of lengthscale to noise
sigma_summary_one <- lapply(fits_one, FUN = function(fit) summary(fit)$summary["sigma_phi", ])
df_sigma_one <- list_to_df(sigma_summary_one)

pdf("1-recovery-sigma.pdf", h = 3, w = 6.25)

ggplot(df_sigma_one, aes(x = replicate, y = mean)) +
  geom_point() +
  geom_errorbar(aes(ymin = X2.5., ymax = X97.5.)) +
  geom_hline(yintercept = 1, size = 0.75, col = "grey", alpha = 0.75) +
  labs(x = "Replicate", y = "Posterior CrI", title = "Is sigma = 1 recovered?") +
  theme_minimal()

dev.off()

pdf("1-lengthscale-sigma-relationship-mean.pdf", h = 3, w = 3)

plot(df_sigma_one$mean, df_lengthscale_one$mean)

dev.off()

lengthscale_draws_one <- lapply(fits_one, FUN = function(fit) as.data.frame(rstan::extract(fit)$l))
sigma_draws_one <- lapply(fits_one, FUN = function(fit) as.data.frame(rstan::extract(fit)$sigma_phi))

#' Contour plots of lengthscale and sigma

pdf("1-lengthscale-sigma-relationship-contour.pdf", h = 5, w = 6.25)

cbind(bind_rows(lengthscale_draws_one, .id = "replicate"), bind_rows(sigma_draws_one)) %>%
  rename("l" = "rstan::extract(fit)$l", "sigma_phi" = "rstan::extract(fit)$sigma_phi") %>%
  ggplot(aes(x = l, y = sigma_phi, col = as.factor(replicate))) +
  geom_density2d() +
  labs(x = "Length-scale",
       y = "Spatial random effect standard deviation",
       col = "Replicate",
       subtitle = "Tend to observe positive correlation in the samples") +
  theme_minimal()

dev.off()

#' l = 3
#' TODO: Replicate this analysis for l = 3

# ck_three <- sim_ck(grid, nsim = 30, l = 3, save = FALSE)
#
# fits_three <- lapply(ck_three, FUN = function(x) bsae::ck_stan(x$sf))
# lengthscale_summary_three <- lapply(fits_three, FUN = function(fit) summary(fit)$summary["l", ])
# df_lengthscale_three <- list_to_df(lengthscale_summary_three)
#
# ggplot(df_lengthscale_three, aes(x = replicate, y = mean)) +
#   geom_point() +
#   geom_errorbar(aes(ymin = X2.5., ymax = X97.5.)) +
#   geom_hline(yintercept = 3, col = lightblue, size = 1.5)
#
# hist(df_lengthscale_three$mean - 3, breaks = 15)
# mean(df_lengthscale_three$mean - 3)

#' What does the prior look like, Gamma(1, 1)
ggplot(data = data.frame(x = c(0, 10)), aes(x)) +
  stat_function(fun = dgamma, n = 101, args = list(1, 1))

#' Note: Nyquist-Shannon sampling theorem
#' https://en.wikipedia.org/wiki/Nyquist%E2%80%93Shannon_sampling_theorem
