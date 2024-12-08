
<!-- README.md is generated from README.Rmd. Please edit that file -->

# qexplore <a href="https://github.com/jarvisc1/qexplore"><img src="man/figures/logo.png" align="right" height="139" alt="qexplore website" /></a>

<!-- badges: start -->

<!-- [![R-CMD-check](https://github.com/jarvic1/qexplore/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jarvic1/qexplore/actions/workflows/R-CMD-check.yaml) -->

<!-- [![CRAN status](https://www.r-pkg.org/badges/version/qexplore)](https://CRAN.R-project.org/package=qexplore) -->

<!-- badges: end -->

The goal of `qexplore` is to streamline the process of exploring and
interrogating data. It allows users to quickly list rows of a data frame
that meet certain criteria or tabulate data based on specific
conditions.

There are two functions `qlist` and `qtab` and they allow you to quickly
list or tabulate your data.

- `qlist` is tidyverse compatiable as the input and output is a
  `data.frame`.
- `qtab` is also compatible with `tidyverse` as the input is a
  `data.frame` and the output is a `tabyl`
- This also has the unintended consequence that it can be combined with
  `gt` and `flextable`.

## Installation

You can install `qexplore` from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("jarvisc1/qexplore")
```

`qexplore` is not currently available on
[CRAN](https://cran.r-project.org/).

## Usage

Here are some examples of how to use `qexplore`. First we look at
`qlist` and then `qtab`.

The real power of these commands comes from three arguments.

- `if_`: this is like filter in dplyr, or the `df[**here**, ]` in base
  or data.table or the `if` option in `Stata` where the command would be
  written as `list var1 if var2 == 1`
- `in_`: this allows you to select the rows that you’d like to look at
  very similar to the `in` option in `Stata` or filtering by rows with
  base or `data.table`.
- `by_`: Only for `qtab` this allow for a 2x2 table to be printing
  several times by a third variable. Similar to doing a `table()` by
  three variables but I prefer this syntax as I think it’s cleaner.
  **Note:** using `by_` will result in the output being a list of
  `tabyl` so I doubt it will be compatible with `gt` or `flex.table`.

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

### Relation to tidyverse

`qlist` takes a dataframe as input and outputs a dataframe. Therefore it
can be connected to other tidyverse functions.

``` r
library(qexplore)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

# Example dataset
data <- data.frame(
  drink_type = c("Latte", "Espresso", "Cappuccino", "Americano"),
  size = c("Small", "Large", "Medium", "Large"),
  day_of_week = c("Mon", "Tue", "Wed", "Thu")
)

# List specific rows
data |> 
  filter(size %in% c("Small", "Large")) |> 
  mutate(fav_drink = if_else(drink_type == "Latte", "Fav Drink", "Rubbish Drinks")) |> 
  qlist(drink_type, fav_drink, size, day_of_week, in_ = 1:2) |> 
  arrange(fav_drink)
#> 
#> ── List Details: ───────────────────────────────────────────────────────────────
#> Columns: drink_type, fav_drink, size, day_of_week
#> Filter: None
#> Rows 1:2
#>   drink_type      fav_drink  size day_of_week
#> 1      Latte      Fav Drink Small         Mon
#> 2   Espresso Rubbish Drinks Large         Tue
```

### Tabulating Data

Use `qtab` to create summary tables:

``` r
larger_data <- data.frame(
  drink_type = sample(data$drink_type, 200, replace = TRUE),
  size = sample(data$size, 200, replace = TRUE),
  day_of_week = sample(c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"), 200, replace = TRUE),
  quantity = sample(1:5, 200, replace = TRUE),  # Add variability for quantity
  price = round(runif(200, 2.5, 6.5), 2)       # Add a random price column
)



# Tabulate a single variable
larger_data |>
  qtab(drink_type)
#> 
#> ── Table Details: ──────────────────────────────────────────────────────────────
#> Columns: drink_type
#> Filter: None
#> Rows: All
#> Group: None
#>  drink_type   n percent
#>   Americano  48   24.0%
#>  Cappuccino  53   26.5%
#>    Espresso  47   23.5%
#>       Latte  52   26.0%
#>       Total 200  100.0%

# Tabulate two variables
larger_data |>
  qtab(drink_type, size)
#> 
#> ── Table Details: ──────────────────────────────────────────────────────────────
#> Columns: drink_type, size
#> Filter: None
#> Rows: All
#> Group: None
#>  drink_type       Large     Medium      Small        Total
#>   Americano 11.0%  (22)  7.5% (15)  5.5% (11)  24.0%  (48)
#>  Cappuccino 15.0%  (30)  4.0%  (8)  7.5% (15)  26.5%  (53)
#>    Espresso 11.5%  (23)  7.0% (14)  5.0% (10)  23.5%  (47)
#>       Latte 13.5%  (27)  5.5% (11)  7.0% (14)  26.0%  (52)
#>       Total 51.0% (102) 24.0% (48) 25.0% (50) 100.0% (200)

# Grouped tabulations
larger_data |> 
  filter(day_of_week %in% c("Mon", "Tues")) |> 
  qtab(drink_type, size, by_ = day_of_week)
#> 
#> ── Table Details: ──────────────────────────────────────────────────────────────
#> Columns: drink_type, size
#> Filter: None
#> Rows: All
#> Group By: day_of_week
#> $Mon
#>  drink_type      Large    Medium     Small       Total
#>   Americano 12.0%  (3)  8.0% (2) 12.0% (3)  32.0%  (8)
#>  Cappuccino 12.0%  (3)  0.0% (0)  0.0% (0)  12.0%  (3)
#>    Espresso 12.0%  (3) 12.0% (3)  0.0% (0)  24.0%  (6)
#>       Latte 16.0%  (4)  8.0% (2)  8.0% (2)  32.0%  (8)
#>       Total 52.0% (13) 28.0% (7) 20.0% (5) 100.0% (25)
```

### Tabulating Data with different percentages

Use `qtab` with different percentages:

``` r

# Tabulate two variables
larger_data |>
  qtab(drink_type, size, per = "all")
#> 
#> ── Table Details: ──────────────────────────────────────────────────────────────
#> Columns: drink_type, size
#> Filter: None
#> Rows: All
#> Group: None
#>  drink_type       Large     Medium      Small        Total
#>   Americano 11.0%  (22)  7.5% (15)  5.5% (11)  24.0%  (48)
#>  Cappuccino 15.0%  (30)  4.0%  (8)  7.5% (15)  26.5%  (53)
#>    Espresso 11.5%  (23)  7.0% (14)  5.0% (10)  23.5%  (47)
#>       Latte 13.5%  (27)  5.5% (11)  7.0% (14)  26.0%  (52)
#>       Total 51.0% (102) 24.0% (48) 25.0% (50) 100.0% (200)

# column percentages
larger_data |>
  qtab(drink_type, size, per = "col")
#> 
#> ── Table Details: ──────────────────────────────────────────────────────────────
#> Columns: drink_type, size
#> Filter: None
#> Rows: All
#> Group: None
#>  drink_type        Large      Medium       Small        Total
#>   Americano  21.6%  (22)  31.2% (15)  22.0% (11)  24.0%  (48)
#>  Cappuccino  29.4%  (30)  16.7%  (8)  30.0% (15)  26.5%  (53)
#>    Espresso  22.5%  (23)  29.2% (14)  20.0% (10)  23.5%  (47)
#>       Latte  26.5%  (27)  22.9% (11)  28.0% (14)  26.0%  (52)
#>       Total 100.0% (102) 100.0% (48) 100.0% (50) 100.0% (200)

# row percentages
larger_data |>
  qtab(drink_type, size, per = "row")
#> 
#> ── Table Details: ──────────────────────────────────────────────────────────────
#> Columns: drink_type, size
#> Filter: None
#> Rows: All
#> Group: None
#>  drink_type       Large     Medium      Small        Total
#>   Americano 45.8%  (22) 31.2% (15) 22.9% (11) 100.0%  (48)
#>  Cappuccino 56.6%  (30) 15.1%  (8) 28.3% (15) 100.0%  (53)
#>    Espresso 48.9%  (23) 29.8% (14) 21.3% (10) 100.0%  (47)
#>       Latte 51.9%  (27) 21.2% (11) 26.9% (14) 100.0%  (52)
#>       Total 51.0% (102) 24.0% (48) 25.0% (50) 100.0% (200)
# no percentages
larger_data |>
  qtab(drink_type, size, per = "none")
#> 
#> ── Table Details: ──────────────────────────────────────────────────────────────
#> Columns: drink_type, size
#> Filter: None
#> Rows: All
#> Group: None
#>  drink_type Large Medium Small Total
#>   Americano    22     15    11    48
#>  Cappuccino    30      8    15    53
#>    Espresso    23     14    10    47
#>       Latte    27     11    14    52
#>       Total   102     48    50   200

# Grouped tabulations
data |>
  qtab(drink_type, size, by_ = day_of_week, per = "none")
#> 
#> ── Table Details: ──────────────────────────────────────────────────────────────
#> Columns: drink_type, size
#> Filter: None
#> Rows: All
#> Group By: day_of_week
#> $Mon
#>  drink_type Small Total
#>       Latte     1     1
#>       Total     1     1
#> 
#> $Tue
#>  drink_type Large Total
#>   Americano     1     1
#>       Total     1     1
#> 
#> $Wed
#>  drink_type Large Total
#>    Espresso     1     1
#>       Total     1     1
#> 
#> $Thu
#>  drink_type Medium Total
#>  Cappuccino      1     1
#>       Total      1     1
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

### Relation to tidyverse

`qtab` outputs a `tabyl` `data.frame` object. Therefore `qtab` can be
piped into anything that `tabyl` can (I think?)

``` r
library(qexplore)
library(dplyr)
library(janitor)
#> Warning: package 'janitor' was built under R version 4.3.3
#> 
#> Attaching package: 'janitor'
#> The following objects are masked from 'package:stats':
#> 
#>     chisq.test, fisher.test
library(gt)
library(flextable)

# Tabulate specific rows
data |>
  qtab(drink_type, size, in_ = 1:3) |> 
   adorn_title(col_name = "Drink size", row_name = "Drink Type")
#> 
#> ── Table Details: ──────────────────────────────────────────────────────────────
#> Columns: drink_type, size
#> Filter: None
#> Rows 1:3
#> Group: None
#>             Drink size                               
#>  Drink Type      Large    Medium     Small      Total
#>  Cappuccino   0.0% (0) 33.3% (1)  0.0% (0)  33.3% (1)
#>    Espresso  33.3% (1)  0.0% (0)  0.0% (0)  33.3% (1)
#>       Latte   0.0% (0)  0.0% (0) 33.3% (1)  33.3% (1)
#>       Total  33.3% (1) 33.3% (1) 33.3% (1) 100.0% (3)
```

### Relation to gt and flextable

Due to `qtab` being a `tabyl`, this has the consequence that it can be
piped into `gt` and `flextable` though this is the purpose as qexplore
is about quickly exploring data via the console. This is a nice feature
maybe this will have some unintended consequences.

``` r
library(qexplore)
library(dplyr)
library(janitor)
library(gt)

# Tabulate specific rows
gt_table <- data |>
  qtab(drink_type, size, in_ = 1:3) |> 
  gt() |> 
    tab_header(
    title = "Drink Types by Day of the Week",
    subtitle = "Percentage Breakdown with Totals"
  )
#> 
#> ── Table Details: ──────────────────────────────────────────────────────────────
#> Columns: drink_type, size
#> Filter: None
#> Rows 1:3
#> Group: None
```

![](man/figures/gt_table.png)

``` r
library(qexplore)
library(dplyr)
library(janitor)
library(flextable)

# Tabulate specific rows
tabyl_data <- data |>
  qtab(drink_type, size, in_ = 1:3) 
#> 
#> ── Table Details: ──────────────────────────────────────────────────────────────
#> Columns: drink_type, size
#> Filter: None
#> Rows 1:3
#> Group: None

# Convert tabyl to flextable
flex_table <- tabyl_data |> 
  flextable() |> 
  set_header_labels(
    drink_type = "Drink Type",
    Total = "Weekly Total"
  ) |> 
  add_header_row(
    values = c("", "Day of the Week"), colwidths = c(1, ncol(tabyl_data) - 1)
  ) |> 
  theme_vanilla() |> 
  autofit()

# View the flextable
flex_table
```

<img src="man/figures/README-unnamed-chunk-10-1.png" width="100%" />

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
