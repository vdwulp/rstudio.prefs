pretty_print_updates <- function(old, new) {
  # create data frame with old and new preferences -----------------------------
  df_updates <-
    # data frame of old prefs
    tibble::tibble(
      pref =
        names(old) %>%
        intersect(names(new)) %||%
        character(0), # if no overlap with old and new, drop in a placeholder,
      old_value =
        old[names(old) %>% intersect(names(new))] %>%
        unname() %>% purrr::map_chr(function(x) if (is.null(x)) "*" else as.character(x)) %||%
        character(0) # if no overlap with old and new, drop in a placeholder
    ) %>%
    dplyr::full_join(
      # data frame of new prefs
      tibble::tibble(
        pref = names(new),
        new_value =
          new %>%
          unname() %>%
          purrr::map_chr(function(x) if (is.null(x)) "*" else as.character(x))
      ),
      by = "pref"
    ) %>%
    dplyr::mutate(
      old_value = ifelse(is.na(.data$old_value), "*", .data$old_value),
      new_value = ifelse(is.na(.data$new_value), "*", .data$new_value),
      updated = .data$old_value != .data$new_value
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
