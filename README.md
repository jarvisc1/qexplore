
<!-- README.md is generated from README.Rmd. Please edit that file -->

# qexplore

<!-- # qexplore <a href="https://github.com/jarvisc1/qexplore"><img src="man/figures/logo.svg" align="right" height="139" alt="qexplore website" /></a> -->

<!-- badges: start -->

<!-- [![R-CMD-check](https://github.com/jarvic1/qexplore/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jarvic1/qexplore/actions/workflows/R-CMD-check.yaml) -->

<!-- [![CRAN status](https://www.r-pkg.org/badges/version/qexplore)](https://CRAN.R-project.org/package=qexplore) -->

<!-- badges: end -->

The goal of `qexplore` is to streamline the process of exploring and
interrogating data. It allows users to quickly list rows of a data frame
that meet certain criteria or tabulate data based on specific
conditions.

## Installation

You can install `qexplore` from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("jarvisc1/qexplore")
```

`qexplore` is not currently available on
[CRAN](https://cran.r-project.org/).

## Usage

Here are some examples of how to use `qexplore`. For more, refer to the
[documentation](https://github.com/jarvic1/qexplore).

### Listing Rows

Use `qlist` to filter and explore subsets of data:

``` r
library(qexplore)

# Example dataset
data <- data.frame(
  drink_type = c("Latte", "Espresso", "Cappuccino", "Americano"),
  size = c("Small", "Large", "Medium", "Large"),
  day_of_week = c("Mon", "Tue", "Wed", "Thu")
)

# List specific rows
data |>
  qlist(drink_type, size, day_of_week, in_ = 1:2)
#> 
#> ── List Details: ───────────────────────────────────────────────────────────────
#> Columns: drink_type, size, day_of_week
#> Filter: None
#> Rows 1:2
#>   drink_type  size day_of_week
#> 1      Latte Small         Mon
#> 2   Espresso Large         Tue

# Filter and list
data |>
  qlist(drink_type, size, if_ = size == "Large")
#> 
#> ── List Details: ───────────────────────────────────────────────────────────────
#> Columns: drink_type, size
#> Filter: size == "Large"
#> Rows: All
#>   drink_type  size
#> 1   Espresso Large
#> 2  Americano Large
```

### Tabulating Data

Use `qtab` to create summary tables:

``` r
# Tabulate a single variable
data |>
  qtab(drink_type)
#> 
#> ── Table Details: ──────────────────────────────────────────────────────────────
#> Columns: drink_type
#> Filter: None
#> Rows: All
#> Group: None
#>  drink_type n percent
#>   Americano 1   25.0%
#>  Cappuccino 1   25.0%
#>    Espresso 1   25.0%
#>       Latte 1   25.0%
#>       Total 4  100.0%

# Tabulate two variables
data |>
  qtab(drink_type, size)
#> 
#> ── Table Details: ──────────────────────────────────────────────────────────────
#> Columns: drink_type, size
#> Filter: None
#> Rows: All
#> Group: None
#>  drink_type     Large    Medium     Small      Total
#>   Americano 25.0% (1)  0.0% (0)  0.0% (0)  25.0% (1)
#>  Cappuccino  0.0% (0) 25.0% (1)  0.0% (0)  25.0% (1)
#>    Espresso 25.0% (1)  0.0% (0)  0.0% (0)  25.0% (1)
#>       Latte  0.0% (0)  0.0% (0) 25.0% (1)  25.0% (1)
#>       Total 50.0% (2) 25.0% (1) 25.0% (1) 100.0% (4)

# Grouped tabulations
data |>
  qtab(drink_type, size, by_ = day_of_week)
#> 
#> ── Table Details: ──────────────────────────────────────────────────────────────
#> Columns: drink_type, size
#> Filter: None
#> Rows: All
#> Group By: day_of_week
#> $Mon
#>  drink_type      Small      Total
#>       Latte 100.0% (1) 100.0% (1)
#>       Total 100.0% (1) 100.0% (1)
#> 
#> $Tue
#>  drink_type      Large      Total
#>   Americano 100.0% (1) 100.0% (1)
#>       Total 100.0% (1) 100.0% (1)
#> 
#> $Wed
#>  drink_type      Large      Total
#>    Espresso 100.0% (1) 100.0% (1)
#>       Total 100.0% (1) 100.0% (1)
#> 
#> $Thu
#>  drink_type     Medium      Total
#>  Cappuccino 100.0% (1) 100.0% (1)
#>       Total 100.0% (1) 100.0% (1)
```

### Advanced Tabulations

``` r
# Tabulate with a filter condition
data |>
  qtab(drink_type, size, if_ = size == "Large")
#> 
#> ── Table Details: ──────────────────────────────────────────────────────────────
#> Columns: drink_type, size
#> Filter: size == "Large"
#> Rows: All
#> Group: None
#>  drink_type      Large      Total
#>   Americano  50.0% (1)  50.0% (1)
#>    Espresso  50.0% (1)  50.0% (1)
#>       Total 100.0% (2) 100.0% (2)

# Tabulate specific rows
data |>
  qtab(drink_type, size, in_ = 1:3)
#> 
#> ── Table Details: ──────────────────────────────────────────────────────────────
#> Columns: drink_type, size
#> Filter: None
#> Rows 1:3
#> Group: None
#>  drink_type     Large    Medium     Small      Total
#>  Cappuccino  0.0% (0) 33.3% (1)  0.0% (0)  33.3% (1)
#>    Espresso 33.3% (1)  0.0% (0)  0.0% (0)  33.3% (1)
#>       Latte  0.0% (0)  0.0% (0) 33.3% (1)  33.3% (1)
#>       Total 33.3% (1) 33.3% (1) 33.3% (1) 100.0% (3)

# Group and filter tabulations
data |>
  qtab(drink_type, size, by_ = day_of_week, if_ = day_of_week %in% c("Mon", "Tue"))
#> 
#> ── Table Details: ──────────────────────────────────────────────────────────────
#> Columns: drink_type, size
#> Filter: day_of_week %in% c("Mon", "Tue")
#> Rows: All
#> Group By: day_of_week
#> $Mon
#>  drink_type      Small      Total
#>       Latte 100.0% (1) 100.0% (1)
#>       Total 100.0% (1) 100.0% (1)
#> 
#> $Tue
#>  drink_type      Large      Total
#>    Espresso 100.0% (1) 100.0% (1)
#>       Total 100.0% (1) 100.0% (1)
```

<!-- ## Documentation -->

<!-- The following resources will help you get started: -->

<!-- - [Package index](https://github.com/jarvic1/qexplore/reference)   -->

<!-- Overview of all `qexplore` functions. -->

<!-- - [Getting started guide](https://github.com/jarvic1/qexplore/articles/qexplore.html)   -->

<!-- Introductory guide to using `qexplore`. -->

<!-- - [Examples](https://github.com/jarvic1/qexplore/examples)   -->

<!-- Real-world examples of data exploration with `qexplore`. -->

## Acknowledgements

This package brings together if, in, and by arguments from Stata. It
replicates something similar that you can do in `data.table`. It also
fits a tidyverse framework and uses tidyverse especially `dplyr` and
`janitor`.

I’d like to thank everyone that was involved in all of the software
above. Especially `tidyplots` for the idea that you can take something
as well established as `ggplot2` and still make something possibly
quicker and maybe more accessible that might help enable more people to
use R.

`qexplore` leverages the following amazing packages to do the heavy
lifting: cli, dplyr, rlang, tidyselect, and tidyr.
