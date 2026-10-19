#' @importFrom dplyr %>%
#' @importFrom purrr %||%
#' @importFrom rlang .data
#' @keywords internal
"_PACKAGE"

# allowing for the use of the dot when piping
utils::globalVariables(".")

# primitive base function bindings required for mocking in covr tests
interactive <- NULL
