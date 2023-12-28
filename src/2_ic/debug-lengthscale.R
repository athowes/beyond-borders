survey <- "zwe2016phia"
inf_function <- arealutils::ck_aghq
f <- "ck_aghq"

message("Begin fitting of ", f, " to the survey ", toupper(survey))
sf <- readRDS(paste0("depends/", survey, ".rds"))

#' Begin expose ck_aghq()
k <- 3
ii <- NULL

D <- centroid_distance(sf)

if(units(D)$numerator == "m") {
  D <- units::set_units(D, "km")
}

D_nonzero <- as.vector(D)[as.vector(D) > 0]
lb <- quantile(D_nonzero, 0.05)
ub <- quantile(D_nonzero, 0.95)

# Parameters of the length-scale prior
param <- arealutils::invgamma_prior(lb = lb, ub = ub, plb = 0.05, pub = 0.05)

dat <- list(n = nrow(sf),
            y = sf$y,
            m = sf$n_obs,
            left_out = !is.null(ii),
            ii = if(!is.null(ii)) ii else 0,
            a = param$a,
            b = param$b,
            D = D)

param <- list(beta_0 = 0,
              u = rep(0, dat$n),
              log_sigma_u = 0,
              log_l = 0)

obj <- TMB::MakeADFun(
  data = c(model = "centroid", dat),
  parameters = param,
  random = c("beta_0", "u"),
  DLL = "arealutils_TMBExports"
)

quad <- aghq::marginal_laplace_tmb(ff = obj, k = k, startingvalue = obj$par)
samples <- aghq::sample_marginal(quad, M = 1000)
log_l_samples <- samples$thetasamples[[2]]
l_samples <- exp(log_l_samples)

#' Observe the difference here
plot(l_samples)
mean(D)

fit <- arealutils::ck_aghq(sf, k = 3, ii = NULL)
samples <- aghq::sample_marginal(fit, M = 1000)
log_l_samples <- samples$thetasamples[[2]]
l_samples <- exp(log_l_samples)

#' Observe the difference here
plot(l_samples)
mean(D)
