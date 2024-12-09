library(testthat)
library(qexplore)

test_that("qtab creates a frequency table", {
  data <- data.frame(
    drink_type = c("Latte", "Espresso", "Latte", "Cappuccino"),
    size = c("Small", "Large", "Small", "Medium")
  )

  result <- data |>
    qtab(drink_type)

  expect_true("Latte" %in% result$drink_type)
  expect_true("Espresso" %in% result$drink_type)
  expect_equal(nrow(result), 4)
})

test_that("qtab cross-tabulates correctly", {
  data <- data.frame(
    drink_type = c("Latte", "Espresso", "Latte", "Cappuccino"),
    size = c("Small", "Large", "Small", "Medium")
  )

  result <- data |>
    qtab(drink_type, size)

  expect_true("Small" %in% colnames(result))
  expect_true("Large" %in% colnames(result))
  expect_true("Latte" %in% result$drink_type)
  expect_true("Cappuccino" %in% result$drink_type)
})

test_that("qtab applies filter with .if", {
  data <- data.frame(
    drink_type = c("Latte", "Espresso", "Latte", "Cappuccino"),
    size = c("Small", "Large", "Small", "Medium"),
    day_of_week = c("Mon", "Tue", "Tue", "Wed")
  )

  result <- data |>
    qtab(drink_type, .if = day_of_week == "Tue")

  expect_true("Latte" %in% result$drink_type)
  expect_true("Espresso" %in% result$drink_type)
  expect_equal(nrow(result), 3)
})

test_that("qtab limits rows with .in", {
  data <- data.frame(
    drink_type = c("Latte", "Espresso", "Cappuccino", "Americano"),
    size = c("Small", "Large", "Medium", "Large")
  )

  result <- data |>
    qtab(drink_type, .in = 1:2)

  expect_equal(nrow(result), 3)
  expect_true("Latte" %in% result$drink_type)
  expect_true("Espresso" %in% result$drink_type)
})

test_that("qtab combines .if and .in", {
  data <- data.frame(
    drink_type = c("Latte", "Espresso", "Latte", "Cappuccino"),
    size = c("Small", "Large", "Small", "Medium"),
    day_of_week = c("Mon", "Tue", "Tue", "Wed")
  )

  result <- data |>
    qtab(drink_type, .if = day_of_week == "Tue", .in = 2:3)

  expect_equal(nrow(result), 3)
  expect_equal(result$drink_type, c("Espresso", "Latte", "Total"))
})

test_that("qtab groups correctly with .by", {
  data <- data.frame(
    drink_type = c("Latte", "Espresso", "Latte", "Cappuccino"),
    size = c("Small", "Large", "Small", "Medium"),
    day_of_week = c("Mon", "Tue", "Mon", "Wed")
  )

  result <- data |>
    qtab(drink_type, size, .by = day_of_week)

  expect_equal(length(result), 3) # Groups: Mon, Tue, Wed
  expect_equal(nrow(result[["Mon"]]), 2)
  expect_true("Latte" %in% result[["Mon"]]$drink_type)
})

test_that("qtab handles empty data frames gracefully and emits a warning", {
  data <- data.frame()
  expect_warning(
    result <- data |>
      qtab(),
    regexp = "The data frame is empty"
  )

  expect_equal(nrow(result), 0)
  expect_equal(ncol(result), 0)
})

test_that("qtab handles no matching rows from .if", {
  data <- data.frame(
    drink_type = c("Latte", "Espresso", "Cappuccino"),
    size = c("Small", "Large", "Medium"),
    day_of_week = c("Mon", "Tue", "Wed")
  )

  result <- data |>
    qtab(drink_type, .if = size == "Extra Large")

  expect_equal(nrow(result), 0)
})
