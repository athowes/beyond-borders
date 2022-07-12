# orderly::orderly_develop_start("check_xbinomial-sampling")
# setwd("src/check_xbinomial-sampling")

#' Test of sampling from the distribution produced by custom likelihood: xbinomial_lpdf
temp1 <- rstan::stan(file = "xbinom.stan", data = list(m = 10, rho = 0.5), warmup = 400, iter = 600, verbose = TRUE)
rstan::summary(temp1)$summary
out1 <- rstan::extract(temp1)
plot(out1$y)
hist(out1$y)

#' Test of sampling from the distribution produced by custom likelihood: xbinomial_logit_lpdf
temp2 <- rstan::stan(file = "xbinom_logit.stan", data = list(m = 10, eta = 0), warmup = 100, iter = 900, verbose = TRUE)
rstan::summary(temp2)$summary
out2 <- rstan::extract(temp2)
plot(out2$y)
hist(out2$y)

df1 <- data.frame(x = out1$y)
df2 <- data.frame(x = out2$y)

ks.test(out1$y, out2$y)

pdf("xbinom-ecdf-comparison.pdf", h = 4, w = 6.25)

ggplot() +
  stat_ecdf(data = df1, aes(x = x), geom = "step") +
  stat_ecdf(data = df2, aes(x = x), geom = "step", col = "red")

dev.off()
