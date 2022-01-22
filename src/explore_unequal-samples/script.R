# orderly::orderly_develop_start("explore_unequal-samples")
# setwd("src/explore_unequal-samples")

#' Development of sampling unequal numbers of points from within each area
L <- 10
n <- nrow(mw)

hexagonal <- sf::st_sample(mw, size = rep(L, n), type = "hexagonal", exact = TRUE)
sample_index <- sf::st_intersects(mw, hexagonal)

#' Not all the same!
sample_lengths <- lengths(sample_index)
max_length <- max(sample_lengths)

padded_sample_index <- lapply(sample_index, function(x) {
  diff <- max_length - length(x)
  append(x, values = rep(NA, diff))
})

#' Three different ways to do this:

#' 1. Padded data structure
matrix(unlist(padded_sample_index), nrow = n, ncol = max_length, byrow = TRUE)

#' 2. Database structure
group_db <- data.frame(i = unlist(sample_index), group_id = rep(seq(length(sample_index)), lengths(sample_index)))

#' 3. Start index structure
start_index <- sapply(sample_index, function(x) x[1])
