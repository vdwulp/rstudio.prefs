#' @importFrom dplyr %>%
#' @importFrom purrr %||%
#' @importFrom rlang .data
#' @keywords internal
"_PACKAGE"

# allowing for the use of the dot when piping
utils::globalVariables(".")

# primitive base function bindings required for mocking in covr tests
interactive <- NULL

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
## usethis namespace: end
NULL
