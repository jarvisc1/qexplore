#' Filter and Display Data with Metadata
#'
#' This function filters and selects variables from a data frame, providing metadata
#' about the selected data. It handles filtering conditions and row selections, displaying
#' useful details for the user.
#'
#' @param data A data frame to be filtered and processed.
#' @param ... One or more column names (unquoted) to select. Supports tidy evaluation.
#' @param .if An optional filter condition (using tidy evaluation) to subset the data.
#' @param .in An optional integer vector specifying rows to include or exclude. Negative values
#'            indicate rows to exclude from the end, while positive values indicate rows to include.
#'
#' @return A filtered and selected data frame.
#'
#' @details
#' The function provides a quick way to explore and filter data:
#'
#' \itemize{
#'   \item Columns are selected using tidy evaluation syntax.
#'   \item Filtering is applied using the `.if` parameter with tidy evaluation.
#'   \item Row selection is possible using the `.in` parameter, supporting both inclusion and exclusion.
#'   \item Metadata about selected columns, filter conditions, and rows is displayed in the console.
#'   \item For more than 10 columns, the display shows "More than 10" instead of listing all columns.
#'   \item Consecutive row numbers are displayed as ranges (e.g., "1:5" instead of "1, 2, 3, 4, 5").
#' }
#'
#' @examples
#' # Sample dataset: Coffee shop orders (20 rows)
#' set.seed(1986)
#' coffee_orders <- data.frame(
#'   order_id = 1:20,
#'   drink_type = sample(c("Espresso", "Latte", "Cappuccino", "Americano"), 20, replace = TRUE),
#'   size = sample(c("Small", "Medium", "Large"), 20, replace = TRUE),
#'   add_milk = sample(c("Yes", "No"), 20, replace = TRUE),
#'   day_of_week = sample(c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"), 20, replace = TRUE)
#' )
#'
#' # Select specific columns
#' coffee_orders |>
#'   qlist(drink_type, size, day_of_week)
#'
#' # Apply a filter condition
#' coffee_orders |>
#'   qlist(drink_type, size, add_milk, .if = size == "Large")
#'
#' # Select specific rows
#' coffee_orders |>
#'   qlist(drink_type, size, day_of_week, .in = 1:5)
#'
#' # Select last 10 rows
#' coffee_orders |>
#'   qlist(drink_type, size, day_of_week, .in = -10:-1)
#'
#' # Combine filtering and row selection
#' coffee_orders |>
#'   qlist(drink_type, size, day_of_week, .if = day_of_week %in% c("Sat", "Sun"), .in = -10:-1)
#' @export
qlist <- function(data, ..., .if = NULL, .in = NULL) {

  # Early return if data is empty
  if (nrow(data) == 0 || ncol(data) == 0) {
    cli::cli_warn("The data frame is empty. Returning an empty result.")
    return(data.frame())
  }

  # Select variables using tidyselect
  selected_vars <- tidyselect::eval_select(rlang::expr(c(...)), data)

  # If no columns are selected, default to all columns
  if (length(selected_vars) == 0) {
    selected_vars <- setNames(seq_along(data), names(data))
  }

  var_names <- names(selected_vars)

  print(selected_vars)
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

  # Capture the `.if` expression using tidy evaluation
  if_quo <- rlang::enquo(.if)
  if (!rlang::quo_is_null(if_quo)) {
    data <- dplyr::filter(data, !!if_quo)
  }

  # Print metadata
  cli::cli_h1("List Details:")

  # Modify column display if more than 10
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

  # Extract selected columns
  selected_data <- dplyr::select(data, dplyr::all_of(var_names))

  # Return the filtered data frame
  return(selected_data)
}
