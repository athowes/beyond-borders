# beyond-borders

Code for the manuscript Howes, Eaton, Flaxman "Beyond borders: evaluating the suitability of spatial adjacency for small-area estimation" (in preparation).

Small-area estimation models typically use the Besag model, a type of Gaussian Markov random field, to model spatial structure.

<p align="center">
<img src="besag.png" width="500">
</p>

However, for irregular geometries, the assumptions made by the Besag model do not seem plausible.
The Besag model was designed to work well for grids, as are used in image analysis, but in small-area estimation the geometries we encounter, like the districts of a country, are more irregular.

<p align="center">
<img src="simulation-geometries.png" width="700">
</p>

The goal of this work is to determine whether or not, in practice, this matters.
To do so, we consider the performance of eight inferential small-area models:

| Model    | Function |
|:---------|--------------|
| Constant | [`constant_aghq`](https://github.com/athowes/arealutils/blob/master/R/constant.R) |
| Independent and identically distributed | [`iid_aghq`](https://github.com/athowes/arealutils/blob/master/R/iid.R) |
| Besag | [`besag_aghq`](https://github.com/athowes/arealutils/blob/master/R/besag.R) |
| Besag-York-Mollié  2 | [`bym2_aghq`](https://github.com/athowes/arealutils/blob/master/R/bym2.R) |
| Centroid kernel (fixed lengthscale) | [`fck_aghq`](https://github.com/athowes/arealutils/blob/master/R/fck.R) |
| Integrated kernel (fixed lengthscale) | [`fik_aghq`](https://github.com/athowes/arealutils/blob/master/R/fik.R) |
| Centroid kernel | [`ck_aghq`](https://github.com/athowes/arealutils/blob/master/R/ck.R) |
| Integrated kernel | [`ik_aghq`](https://github.com/athowes/arealutils/blob/master/R/ik.R) |

We use the `aghq` package for adaptive Gauss-Hermite quadrature to conduct Bayesian inference for each of the models.
Where possible, alternative implementions using `TMB`, `tmbstan`, `R-INLA` and `rstan` are provided by the `arealutils` package.

## R package dependencies

This analysis is supported by the [`arealutils`](https://github.com/athowes/arealutils) package (I'd usually use the name `areal.utils` but C++ doesn't like having `.` in package names) which can be installed from Github via:

```r
devtools::install_github("athowes/arealutils")
```

The [`aghq`](https://github.com/awstringer1/aghq) package is available from CRAN, though the latest development version can be installed from Github via:

```r
devtools::install_github("awstringer1/aghq")
```

Additionally, if required, the `R-INLA` package is not currently available on CRAN, and instead may be installed by following [instructions](https://www.r-inla.org/download-install) from the project website.

## File structure

The directories of this repository are:

| Directory   | Contains |
|-------------|--------------|
| `make`      | Scripts used to run the reports. `_make.R` runs everything in order. |
| `misc`      | Miscellaneous code, not used as part of `orderly`. |
| `src`       | All `orderly` reports. |
| `utils`     | Helper scripts for common development tasks. |

Within the `src` directory, reports are prefixed by a number (0-2) designating:

| Prefix | Description |
|---------------|--------------|
| 0             | Applicable to both studies. |
| 1             | Corresponds to the study on synthetic data. |
| 2             | Corresponds to the study on HIV data from household surveys in sub-Saharan Africa. |

## `orderly`

We use the [`orderly`](https://github.com/vimc/orderly) package ([RESIDE, 2020](https://reside-ic.github.io/)) to simplify the process of doing reproducible research.
After installing [`orderly`](https://github.com/vimc/orderly) (from either CRAN or Github) a report, let's say called `example`, may be run by:

```r
orderly::orderly_run(name = "src/example")
```

The results of this run will appear in the `draft/` folder (ignored on Github).
To commit the draft (with associated `id`) to the `archive/` folder (also ignored on Github, and which should be treated as "read only") use:

```r
orderly::orderly_commit(id)
```

Any outputs of this report will then be available to use as dependencies within other reports.
