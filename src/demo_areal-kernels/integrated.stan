// integrated.stan

functions {
  real xbinomial_logit_lpdf(real y, real m, real eta) {
    real dens = lchoose(m, y) + y * log(inv_logit(eta)) + (m - y) * log(1 - inv_logit(eta));
    real jacobian = log(inv_logit(eta)) + log(inv_logit(-eta)); // Alternative: eta - 2 * log(1 + exp(eta))
    return dens + jacobian;
  }

  matrix cov_matern32(matrix D, real l) {
    int n = rows(D);
    matrix[n, n] K;
    real norm_K;
    real sqrt3;
    sqrt3 = sqrt(3.0);

    for(i in 1:(n - 1)){
      // Diagonal entries (apart from the last)
      K[i, i] = 1;
      for(j in (i + 1):n){
        // Off-diagonal entries
        norm_K = D[i, j] / l;
        K[i, j] = (1 + sqrt3 * norm_K) * exp(-sqrt3 * norm_K); // Fill lower triangle
        K[j, i] = K[i, j]; // Fill upper triangle
      }
    }
    K[n, n] = 1;

    return(K);
  }

  matrix cov_sample_average(matrix S, real l, int n, int[] start_index, int[] sample_lengths, int total_samples) {
    matrix[n, n] K;
    matrix[total_samples, total_samples] kS = cov_matern32(S, l);

    for(i in 1:(n - 1)) {
      // Diagonal entries (apart from the last)
      K[i, i] = mean(block(kS, start_index[i], start_index[i], sample_lengths[i], sample_lengths[i]));
      for(j in (i + 1):n) {
        // Off-diagonal entries
        K[i, j] = mean(block(kS, start_index[i], start_index[j], sample_lengths[i], sample_lengths[j]));
        K[j, i] = K[i, j];
      }
    }
    K[n, n] = mean(block(kS, start_index[n], start_index[n], sample_lengths[n], sample_lengths[n]));

    return(K);
  }
}

data {
  int<lower=0> n; // Number of region
  vector[n] y; // Vector of observed responses
  vector[n] m; // Vector of sample sizes
  vector[n] mu; // Prior mean vector

  int sample_lengths[n]; // Number of Monte Carlo samples in each area
  int<lower=0> total_samples; // sum(sample_lengths)
  int start_index[n]; // Start indicies for each group of samples
  matrix[total_samples, total_samples] S; // Distances between all points (could be sparser!)
}

parameters {
  real beta_0; // Intercept
  vector[n] phi; // Spatial effects
  real<lower=0> sigma_phi; // Standard deviation of spatial effects
  real<lower=0> l; // Kernel lengthscale
}

transformed parameters {
  vector[n] eta = beta_0 + sigma_phi * phi;
}

model {
  matrix[n, n] K = cov_sample_average(S, l, n, start_index, sample_lengths, total_samples);
  // I could do this?
  // matrix[n, n] L = cholesky_decompose(K);
  // y ~ multi_normal_cholesky(mu, L);
  l ~ gamma(1, 1);
  sigma_phi ~ normal(0, 2.5); // Weakly informative prior
  beta_0 ~ normal(-2, 1);
  phi ~ multi_normal(mu, K);
  for(i in 1:n) {
   y[i] ~ xbinomial_logit(m[i], eta[i]);
  }
}

generated quantities {
  real tau_phi = 1 / sigma_phi^2; // Precision of spatial effects
  vector[n] rho = inv_logit(beta_0 + sigma_phi * phi);
  vector[n] log_lik;
  for (i in 1:n) {
    log_lik[i] = xbinomial_logit_lpdf(y[i] | m[i], eta[i]);
  }
}
