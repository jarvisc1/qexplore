#' Create Tabular Summaries of Data
#'
#' This function generates tabular summaries of data with flexible options
#' for filtering, grouping, and percentage calculations. It provides a quick
#' and easy way to explore and analyze categorical data.
#'
#' @param data A data frame to be tabulated.
#' @param ... One or two variable names (unquoted) to create tabular summaries.
#'            Supports tidy evaluation.
#' @param .if An optional filter condition (using tidy evaluation) to subset the data before tabulation.
#' @param .in An optional integer vector specifying rows to include or exclude. Negative values
#'            indicate rows to exclude from the end, while positive values indicate rows to include.
#' @param per A character string specifying how percentages are calculated. Options are:
#'            `"none"`, `"row"`, `"col"`, or `"all"`. Defaults to `"all"`.
#' @param .by An optional variable (unquoted) to group data by before creating summaries.
#'            Supports tidy evaluation.
#' @param suppress A logical value. If `TRUE`, suppresses metadata output. Defaults to `FALSE`.
#'
#' @return A table or list of tables (if `.by` is used), summarizing the data based on
#'         the specified variables.
#'         \itemize{
#'           \item For one variable: a frequency table with percentages.
#'           \item For two variables: a cross-tabulation with optional percentages and totals.
#'         }
#'
#' @details
#' The function provides a versatile way to create summary tables:
#'
#' \itemize{
#'   \item Single variable tabulation produces a frequency table.
#'   \item Two-variable tabulation creates a cross-tabulation.
#'   \item Using `.by` allows for grouped tabulations across categories.
#'   \item The `.if` parameter enables filtering before tabulation.
#'   \item Row selection is possible using the `.in` parameter.
#'   \item Percentage calculations can be customized with the `per` parameter.
#'   \item Metadata display can be controlled with the `suppress` parameter.
#' }
#'
#' @examples
#' # Sample dataset: Coffee shop orders
#' set.seed(1986)
#' coffee_orders <- data.frame(
#'   order_id = 1:200,
#'   drink_type = sample(c("Espresso", "Latte", "Cappuccino", "Americano"), 200, replace = TRUE),
#'   size = sample(c("Small", "Medium", "Large"), 200, replace = TRUE),
#'   add_milk = sample(c("Yes", "No"), 200, replace = TRUE),
#'   day_of_week = sample(c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"), 200, replace = TRUE)
#' )
#'
#' # Tabulate a single variable
#' coffee_orders |>
#'   qtab(drink_type)
#'
#' # Tabulate with a filter condition
#' coffee_orders |>
#'   qtab(drink_type, .if = day_of_week %in% c("Sat", "Sun"))
#'
#' # Tabulate with specific rows
#' coffee_orders |>
#'   qtab(drink_type, .in = 1:50)
#'
#' # Cross-tabulate two variables
#' coffee_orders |>
#'   qtab(drink_type, size)
#'
#' # Grouped tabulations
#' coffee_orders |>
#'   qtab(drink_type, size, .by = day_of_week)
#' @export
qtab <- function(data, ..., per = "all", .if = NULL, .in = NULL,  .by = NULL,  suppress = FALSE) {

  # Early return if data is empty
  if (nrow(data) == 0 || ncol(data) == 0) {
    cli::cli_warn("The data frame is empty. Returning an empty result.")
    return(data.frame())
  }

  # Match percentage argument, with "all" as default
  per <- match.arg(per, choices = c("none", "row", "col", "all"))

  # Capture `.by` using tidy evaluation
  by_quo <- rlang::enquo(.by)

  # Select variables using tidyselect
  selected_vars <- tidyselect::eval_select(rlang::expr(c(...)), data)
  var_names <- names(selected_vars)

  # Handle positive and negative indices in `.in`
  if (!is.null(.in)) {
    valid_indices <- .in[.in > 0 & .in <= nrow(data)] # Filter valid positive indices
    valid_indices <- c(valid_indices, (nrow(data) + .in[.in < 0] + 1)) # Handle valid negative indices
    valid_indices <- valid_indices[valid_indices > 0 & valid_indices <= nrow(data)] # Recheck bounds

    if (length(valid_indices) == 0) {
      # If no valid indices, return empty data frame with selected columns
      return(data.frame(matrix(ncol = length(var_names), nrow = 0, dimnames = list(NULL, var_names))))
    }
    data <- data[valid_indices, , drop = FALSE]
  }

  # Apply filtering with `.if`
  if_quo <- rlang::enquo(.if)
  if (!rlang::quo_is_null(if_quo)) {
    data <- data |> dplyr::filter(!!if_quo)
    if (nrow(data) == 0) {
      # Return an empty table structure when no rows match the filter
      return(data.frame(matrix(ncol = length(var_names), nrow = 0, dimnames = list(NULL, var_names))))
    }
  }

  # Print metadata only if not suppressed
  if (!suppress) {
    cli::cli_h1("Table Details:")

    if (length(var_names) > 10) {
      cli::cli_text(cli::col_green("Columns: More than 10"))
    } else {
      cli::cli_text(cli::col_green("Columns: ", paste(var_names, collapse = ', ')))
    }

    if (!rlang::quo_is_null(if_quo)) {
      filter_expr <- rlang::expr_text(rlang::quo_get_expr(if_quo))
      cli::cli_text(cli::col_red("Filter: ", filter_expr))
    } else {
      cli::cli_text(cli::col_red("Filter: None"))
    }

    if (!is.null(.in)) {
      rows_info <- if (all(.in < 0)) {
        paste0("Last ", abs(.in[1]))
      } else {
        ranges <- split(.in, cumsum(c(1, diff(.in) != 1)))
        ranges_str <- sapply(ranges, function(r) {
          if (length(r) > 1) paste0(min(r), ":", max(r)) else as.character(r)
        })
        paste("Rows", paste(ranges_str, collapse = ", "))
      }
      cli::cli_text(cli::col_blue(rows_info))
    } else {
      cli::cli_text(cli::col_blue("Rows: All"))
    }

    if (!rlang::quo_is_null(by_quo)) {
      cli::cli_text(cli::col_magenta("Group By: ", rlang::as_label(by_quo)))
    } else {
      cli::cli_text(cli::col_magenta("Group: None"))
    }
  }

  # If `.by` is provided, split data and process each group separately
  if (!rlang::quo_is_null(by_quo)) {
    result <- data |>
      dplyr::group_split(!!by_quo) |>
      setNames(data |> dplyr::distinct(!!by_quo) |> dplyr::pull(!!by_quo)) |>
      lapply(function(group_data) {
        group_label <- unique(group_data |> dplyr::pull(!!by_quo))[1]
        qtab(group_data, ..., per = per, suppress = TRUE)
      })

    return(result)
  }

  # Extract selected columns
  selected_data <- data |> dplyr::select(dplyr::all_of(var_names))

  # Check the number of variables selected
  if (ncol(selected_data) == 1) {
    # Generate frequency table for one variable
    result <- selected_data |>
      janitor::tabyl(!!rlang::sym(var_names[1])) |>
      janitor::adorn_totals() |>
      janitor::adorn_pct_formatting()
  } else if (ncol(selected_data) == 2) {
    # Generate cross-tabulation for two variables
    result <- selected_data |>
      janitor::tabyl(!!rlang::sym(var_names[1]), !!rlang::sym(var_names[2])) |>
      janitor::adorn_totals(where = c("row", "col"))
    if (per != "none") {
      result <- result |>
        janitor::adorn_percentages(per) |>
        janitor::adorn_pct_formatting(digits = 1) |>
        janitor::adorn_ns()
    }
  } else {
    stop("The function only supports up to two variables for tabulation unless using `.by`.")
  }

  return(result)
}


