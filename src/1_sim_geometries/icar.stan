data {
  int<lower=0> n;
  int<lower=1> n_edges;
  int<lower=1, upper=n> node1[n_edges];
  int<lower=1, upper=n> node2[n_edges];
}

parameters {
  vector[n] u;
}

model {
  target += -0.5 * dot_self(u[node1] - u[node2]);
  sum(u) ~ normal(0, 0.001 * n);
}

