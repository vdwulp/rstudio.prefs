#' Pretty Print Updates
#'
#' Prints a formatted summary of changes, grouped into "No Changes" and
#' "Updates" sections. Missing or `NULL` values are shown as `*`, an empty list
#' is shown as `<empty>`.
#'
#' Keys present in `new` but absent in `old` are treated as new additions,
#' with old shown as `*`. Removing a non-existent key (present in `new` as
#' `NULL`, absent in `old`) appears in "No Changes" with both values shown as
#' `*`.
#'
#' @param old named list of current values (may contain `NULL` values)
#' @param new named list of intended new values (may contain `NULL` for removals)
#'
#' @return `TRUE` if any values changed, `FALSE` otherwise
#'
#' @noRd
pretty_print_updates <- function(old, new) {
  # create data frame with old and new preferences -----------------------------
  format_val <- function(x) {
    if (is.null(x)) "*"
    else if (is.list(x) && length(x) == 0L) "<empty>"
    else if (is.list(x)) paste(x, collapse = ", ")
    else as.character(x)
  }

  df_updates <- tibble::tibble(
    pref      = names(new),
    old_value = names(new) %>% lapply(function(nm) format_val(old[[nm]])) %>% unlist(),
    new_value = new %>% unname() %>% lapply(format_val) %>% unlist(),
    updated   = .data$old_value != .data$new_value
  )

  # pad each column with trailing spaces ---------------------------------------
  length_total <- df_updates %>% lapply(function(x) nchar(x) %>% max())
  length_total[["pref"]] <- length_total[["pref"]] + 3
  length_total[["old_value"]] <- length_total[["old_value"]] + 1
  for (i in seq_len(nrow(df_updates))) {
    for (col in setdiff(names(df_updates), "updated")) {
      df_updates[i, col] <-
        paste0(
          df_updates[i, col],
          rep_len(" ", length_total[[col]] - nchar(df_updates[i, col])) %>%
            paste(collapse = "")
        )
    }
  }

  # print updates --------------------------------------------------------------
  if (sum(!df_updates$updated) > 0L) {
    cat(cli::rule("No Changes", line = 2), "\n")
    df_updates %>%
      dplyr::filter(!.data$updated) %>%
      dplyr::mutate(message = paste0(
        "- ",
        .data$pref, "[",
        .data$old_value, " --> ",
        .data$new_value,
        "]"
      )) %>%
      dplyr::pull(.data$message) %>%
      paste(collapse = "\n") %>%
      cat()
    cat("\n\n")
  }

  if (sum(df_updates$updated) > 0L) {
    cat(cli::rule("Updates", line = 2), "\n")
    df_updates %>%
      dplyr::filter(.data$updated) %>%
      dplyr::mutate(message = paste0(
        "- ",
        .data$pref, "[",
        .data$old_value, " --> ",
        .data$new_value,
        "]"
      )) %>%
      dplyr::pull(.data$message) %>%
      paste(collapse = "\n") %>%
      cat()
    cat("\n\n")
  }

  # return a logical indicating if there were any updates
  return(sum(df_updates$updated) > 0L)
}
