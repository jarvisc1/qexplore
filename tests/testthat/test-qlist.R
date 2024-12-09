library(testthat)
library(qexplore)

test_that("qlist selects correct columns", {
  data <- data.frame(
    drink_type = c("Latte", "Espresso", "Cappuccino"),
    size = c("Small", "Large", "Medium"),
    day_of_week = c("Mon", "Tue", "Wed")
  )

  result <- data |>
    qlist(drink_type, size)

  expect_equal(colnames(result), c("drink_type", "size"))
})

test_that("qlist filters rows correctly using .if", {
  data <- data.frame(
    drink_type = c("Latte", "Espresso", "Cappuccino"),
    size = c("Small", "Large", "Medium"),
    day_of_week = c("Mon", "Tue", "Wed")
  )

  result <- data |>
    qlist(drink_type, size, .if = size == "Large")

  expect_equal(nrow(result), 1)
  expect_equal(result$size, "Large")
})

test_that("qlist selects rows correctly using .in", {
  data <- data.frame(
    drink_type = c("Latte", "Espresso", "Cappuccino", "Americano"),
    size = c("Small", "Large", "Medium", "Large"),
    day_of_week = c("Mon", "Tue", "Wed", "Thu")
  )

  result <- data |>
    qlist(drink_type, size, .in = 1:2)

  expect_equal(nrow(result), 2)
  expect_equal(result$drink_type, c("Latte", "Espresso"))
})

test_that("qlist selects last rows using negative .in indices", {
  data <- data.frame(
    drink_type = c("Latte", "Espresso", "Cappuccino", "Americano"),
    size = c("Small", "Large", "Medium", "Large"),
    day_of_week = c("Mon", "Tue", "Wed", "Thu")
  )

  result <- data |>
    qlist(drink_type, size, .in = -2:-1)

  expect_equal(nrow(result), 2)
  expect_equal(result$drink_type, c("Cappuccino", "Americano"))
})

test_that("qlist handles both .if and .in together", {
  data <- data.frame(
    drink_type = c("Latte", "Espresso", "Cappuccino", "Americano"),
    size = c("Small", "Large", "Medium", "Large"),
    day_of_week = c("Mon", "Tue", "Wed", "Thu")
  )

  result <- data |>
    qlist(drink_type, size, .if = size == "Large", .in = 2:3)

  expect_equal(nrow(result), 1)
  expect_equal(result$drink_type, "Espresso")
  expect_equal(result$size, "Large")
})

test_that("qlist handles empty data frames gracefully and emits a warning", {
  data <- data.frame()
  expect_warning(
    result <- data |>
      qlist(),
    regexp = "The data frame is empty"
  )

  expect_equal(nrow(result), 0)
  expect_equal(ncol(result), 0)
})

test_that("qlist returns empty data frame when no rows match .if", {
  data <- data.frame(
    drink_type = c("Latte", "Espresso", "Cappuccino"),
    size = c("Small", "Large", "Medium"),
    day_of_week = c("Mon", "Tue", "Wed")
  )

  result <- data |>
    qlist(drink_type, size, .if = size == "Extra Large")

  expect_equal(nrow(result), 0)
  expect_equal(colnames(result), c("drink_type", "size"))
})

test_that("qlist handles invalid .in indices", {
  data <- data.frame(
    drink_type = c("Latte", "Espresso", "Cappuccino"),
    size = c("Small", "Large", "Medium"),
    day_of_week = c("Mon", "Tue", "Wed")
  )

  result <- data |>
    qlist(drink_type, size, .in = 10:20)

  expect_equal(nrow(result), 0)
  expect_equal(colnames(result), c("drink_type", "size"))
})
