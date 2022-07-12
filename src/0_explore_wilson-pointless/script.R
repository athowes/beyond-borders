# orderly::orderly_develop_start("explore_wilson-pointless")
# setwd("src/explore_wilson-pointless")

set.seed(10)

load("kenya.rdata")

#' Read in population data
#' Follow instructions in pointless-spatial-modeling README as to how to get this
pop.dat <- raster("gpw_v4_population_count_rev11_2015_2pt5_min.tif")
pop.dat <- setMinMax(pop.dat)
kenya.extent <- extent(33.9, 42, -4.7, 5.1)
pop.dat.kenya <- crop(pop.dat, kenya.extent)

kenya.df1 <- fortify(adm0) %>%
  mutate(id = as.numeric(id))

kenya.df47 <- fortify(adm1) %>%
  mutate(id = as.numeric(id))

kenya.df8 <- fortify(adm0.5) %>%
  mutate(id = as.numeric(id) + 1)

#' Set-up variables for simulation
#' * Create mesh for first 5 scenarios: "mesh.true"
#' * Create D matrix used for scenario 2 and 3: "D" (47 x m)
#' * Create D matrix used for scenario 4 and 5: "D8" (see note above)
#' * Add columns to kenya.data indicating which polygons the EAs reside in

# Create internal mesh points
points.kenya <- spsample(adm0, 2500, "regular")

boundary.kenya <- inla.nonconvex.hull(
  points.kenya@coords,
  convex = 0.1,
  resolution = c(120, 120)
)

#' Determine population near these mesh points
pop.at.meshX <- raster::extract(pop.dat.kenya, points.kenya@coords)
pop.at.meshX[is.na(pop.at.meshX)] <- 0
pop.at.mesh <- data.frame(points.kenya@coords)
pop.at.mesh$pop <- pop.at.meshX
names(pop.at.mesh)[1:2] <- c("mlong", "mlat")

#' Make the mesh
mesh.true <- inla.mesh.2d(
  pop.at.mesh[, 1:2],
  offset = c(1, 2),
  max.edge = 1 * c(1, 5)
)

plot(mesh.true)

#' adm1
#' Determine which polys the mesh points live in
meshgrid <- data.frame(
  Longitude = mesh.true$loc[,1],
  Latitude = mesh.true$loc[,2]
)

coordinates(meshgrid) <- ~ Longitude + Latitude
proj4string(meshgrid) <- proj4string(adm1)
meshlocs <- over(meshgrid, adm1)[, 1]
tapply(rep(1, length(meshlocs)), meshlocs, sum)

mesh.df <- data.frame(
  mlong = mesh.true$loc[, 1],
  mlat = mesh.true$loc[, 2],
  loc = meshlocs,
  id = 1:length(meshlocs)
)

#' adm0.5
# Determine which polys the mesh points live in

#' There is slight misalignment of the boundaries, which should completely
#' overlap. Thus, we manually enter the provinces based on which of the 47
#' districts the mesh point is in.
meshlocs8 <- over(meshgrid, adm0.5)[, 1]
mesh.df$loc8X <- meshlocs8
mapping47to8 <- as.vector(apply(table(mesh.df[, c("loc", "loc8X")]), 1, which.max))
mesh.df$loc8 <- mapping47to8[mesh.df$loc]

#' Population at mesh including polygon location
pop.at.mesh <- dplyr::right_join(mesh.df, pop.at.mesh)

#' Create D matrix

#' adm1
D <- inla.spde.make.A(
  mesh = mesh.true,
  loc = as.matrix(pop.at.mesh[,1:2]),
  block = pop.at.mesh$loc,
  weights = pop.at.mesh$pop
)

D.tmp <- list()
D.tmp$D <- D / rowSums(D)
D.tmp$mesh.weights <- colSums(D)
mesh.df$weight.unscaled <- D.tmp$mesh.weights
D <- D.tmp$D

mesh.df$weight.scaled <- colSums(D)
nmesh.area <- 1 / tapply(rep(1, nrow(mesh.df)), mesh.df$loc, sum)
mesh.df$weight.comp <- nmesh.area[mesh.df$loc] #' Comparison weight

#' adm0.5

D8 <- inla.spde.make.A(
  mesh = mesh.true,
  loc = as.matrix(pop.at.mesh[,1:2]),
  block = pop.at.mesh$loc8,
  weights = pop.at.mesh$pop
)

D.tmp8 <- list()
D.tmp8$D <- D8 / rowSums(D8)
D.tmp8$mesh.weights <- colSums(D8)

mesh.df$weight.unscaled8 <- D.tmp8$mesh.weights
D8 <- D.tmp8$D
mesh.df$weight.scaled8 <- colSums(D8)
nmesh.area8 <- 1 / tapply(rep(1, nrow(mesh.df)), mesh.df$loc8, sum)
mesh.df$weight.comp8 <- nmesh.area8[mesh.df$loc8] #' Comparison weight

#' Set-up parameters
alpha <- 0
sigma2 <- 0.25
lambda2 <- 1 - sigma2
erange <- sqrt(8) / exp(0.5)
theta2 <- log(sqrt(8) / erange)
kappa <- exp(theta2)
tau2 <- 1 / (4 * pi * kappa^2 * lambda2)
theta1 <- log(sqrt(tau2))

#' Set-up field
spde <- inla.spde2.matern(mesh.true)
Q.true <- inla.spde.precision(spde, c(theta1, theta2))
field.true <- as.numeric(inla.qsample(1, Q = Q.true, seed = 50L))

#' Connecting field to data
proj.survey <- inla.mesh.projector(
  mesh.true,
  loc = as.matrix(kenya.data[, c("LONGNUM", "LATNUM")])
)
field.survey <- inla.mesh.project(proj.survey, field = field.true)
kenya.data$field <- field.survey
kenya.data$mu <- alpha + kenya.data$field

#' Make matrix that will be used to obtain predictions of the surface
pred.info <- MakePredictionAMatrix(mesh.true, adm0, dims=c(110, 110))
A.pred <- pred.info$A.pred
stkgrid <- inla.stack(
  data = list(y = NA, N = NA),
  A = list(A.pred, 1),
  effects = list(i = 1:spde$n.spde, alpha = rep(1, nrow(A.pred))), tag = 'prd.gr'
)
rel.points.clip <- pred.info$rel.points.clip

#' Simulate data

#' Census
#' Data simulated on 1km x 1km grid
pop.data.kenya.points <- data.frame(rasterToPoints(pop.dat.kenya, spatial = F))
names(pop.data.kenya.points) <- c("long", "lat", "pop")
coordinates(pop.data.kenya.points) <- ~ long + lat
pop.data.kenya.points@proj4string <- adm0@proj4string
pop.pt.insideX <- pop.data.kenya.points[adm0, ]
pop.pt.inside <- as.data.frame(pop.pt.insideX)
coordinates(pop.pt.inside) <- ~ long + lat
pop.pt.inside@proj4string <- adm0@proj4string
