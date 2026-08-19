#' Set RStudio Preferences
#'
#' This function updates the RStudio preferences saved in
#' the `rstudio-prefs.json` file. A full listing of preferences that may be
#' modified are listed here
#' \url{https://docs.posit.co/ide/server-pro/admin/reference/session_user_settings.html}
#'
#' @param ... series of RStudio preferences to update, e.g.
#' `always_save_history = FALSE, rainbow_parentheses = TRUE`
#'
#' @export
#' @return Invisibly returns the updated preferences as a named list on success,
#'   or `NULL` if no updates were made (no changes, user aborted, or not in an
#’   interactive session).
#' @author Daniel D. Sjoberg
#'
#' @examplesIf interactive()
#' # pass preferences individually --------------
#' use_rstudio_prefs(
#'   always_save_history = FALSE,
#'   rainbow_parentheses = TRUE
#' )
#'
#' # pass a list of preferences -----------------
#' pref_list <-
#'   list(always_save_history = FALSE,
#'        rainbow_parentheses = TRUE)
#'
#' use_rstudio_prefs(!!!pref_list)

use_rstudio_prefs <- function(...) {
  # check whether fn may be used -----------------------------------------------
  check_min_rstudio_version("1.3")
  if (!interactive()) {
    "{.code use_rstudio_prefs()} must be run interactively." %>%
      cli::cli_alert_danger()
    return(invisible())
  }

  # save lists of existing and updated prefs -----------------------------------
  list_updated_prefs <- rlang::dots_list(...)
  if (!rlang::is_named(list_updated_prefs)) {
    rlang::abort("Each argument must be named.")
  }

  list_current_prefs <-
    names(list_updated_prefs) %>%
    purrr::map(~rstudioapi::readRStudioPreference(.x, default = NULL)) %>%
    stats::setNames(names(list_updated_prefs)) %>%
    purrr::compact()

  # check each element of list is length one -----------------------------------
  check_prefs_consistency(list_updated_prefs)

  # print updates that will be made --------------------------------------------
  any_update <- pretty_print_updates(list_current_prefs, list_updated_prefs)
  # if no updates, abort function execution
  if (!any_update) {
    return(invisible(NULL))
  }
  # ask user to abort or not
  if (!startsWith(tolower(readline("Would you like to continue? [y/n] ")), "y")) {
    return(invisible(NULL))
  }

  # update prefs ---------------------------------------------------------------
  list_updated_prefs %>%
    purrr::iwalk(~rstudioapi::writeRStudioPreference(name = .y, value = .x))
  return(invisible(list_updated_prefs))
}


#' Check Validity of User-passed Preferences
#'
#'  Function performs some checks of the user inputs, e.g. the name of the
#'  preference is checked against the table from
#'  `fetch_rstudio_prefs()`...if name is not found a warning
#'  message is printed. The type/class of the input is also checked against
#'  the expected class (again taken from `fetch_rstudio_prefs()`)
#'
#' @param x list of user-passed preferences to update/modify
#' @keywords internal
#' @noRd
check_prefs_consistency <- function(x) {
  # check for duplicate names --------------------------------------------------
  if (names(x) %>% duplicated() %>% any()) {
    paste(
      "Duplicate preferences passed:",
      paste(names(x)[names(x) %>% duplicated() %>% which()] %>% unique(),
            collapse = ", ")
    ) %>%
      rlang::abort()
  }

  # check for prefs not listed -------------------------------------------------
  # first grab df of all prefs
  df_all_prefs <- fetch_rstudio_prefs()

  bad_pref_names <- names(x) %>% setdiff(df_all_prefs$property)
  if (length(bad_pref_names) > 0L) {
    paste(
      "{.val {paste(bad_pref_names, sep = ', ')}}",
      "may not be valid RStudio preference names.",
      "Proceed with caution."
    ) %>%
      cli::cli_alert_danger()
  }

  # check passed types ---------------------------------------------------------
  purrr::iwalk(
    x,
    function(.x, .y) {
      pref_def_list <-
        df_all_prefs %>%
        dplyr::filter(.data$property %in% .y) %>%
        as.list()

      # if pref is not found in table, move on to the next checks
      if (rlang::is_empty(pref_def_list$property)) {
        return(invisible(NULL))
      }

      # checking passed arguments against expected types
      if (pref_def_list$class %in% "logical" && !rlang::is_logical(.x)) {
        paste("Expecting {.field {.y}} to be type {.val logical}, but it is not.",
              "Proceed with caution.") %>%
          cli::cli_alert_danger()
      }
      else if (pref_def_list$class %in% "character" && !rlang::is_character(.x)) {
        paste("Expecting {.field {.y}} to be type {.val character}, but it is not.",
              "Proceed with caution.") %>%
          cli::cli_alert_danger()
      }
      else if (pref_def_list$class %in% "integer" && !rlang::is_integerish(.x)) {
        paste("Expecting {.field {.y}} to be type {.val integer}, but it is not.",
              "Proceed with caution.") %>%
          cli::cli_alert_danger()
      }
      else if (pref_def_list$class %in% "numeric" && !is.numeric(.x)) {
        paste("Expecting {.field {.y}} to be type {.val numeric}, but it is not.",
              "Proceed with caution.") %>%
          cli::cli_alert_danger()
      }
      if (pref_def_list$is_scalar && length(.x) > 1) {
        paste("Expecting {.field {.y}} to be length one, but it is not.",
              "Proceed with caution.") %>%
          cli::cli_alert_danger()
      }
    }
  )

  invisible(NULL)
}


#' Fetch table of RStudio Preferences
#'
#' Preferences are fetched from
#' [https://docs.posit.co/ide/server-pro/admin/reference/session_user_settings.html](https://docs.posit.co/ide/server-pro/admin/reference/session_user_settings.html)
#'
#' @section Details:
#' Only preferences of type `"boolean"`, `"string"`, `"number"`, `"integer"`,
#' and `"array"`
#' are fetched from the table.
#' TODO: Research how type `"object"` are passed and include
#' in the fetched preferences table.
#'
#' @return tibble
#' @export
#'
#' @examples
#'
#' fetch_rstudio_prefs()
fetch_rstudio_prefs <- function() {
  url <- "https://docs.posit.co/ide/server-pro/admin/reference/session_user_settings.html"
  cli::cli_alert_success("Downloading list of available {.field RStudio} settings")
  cat("\n")
  tryCatch(
    url %>%
      rvest::read_html() %>%
      rvest::html_nodes("table") %>%
      rvest::html_table(fill = TRUE) %>%
      purrr::pluck(1) %>%
      dplyr::rename_with(tolower) %>%
      dplyr::mutate(
        class =
          dplyr::case_when(
            .data$type %in% "boolean" ~ "logical",
            .data$type %in% "integer" ~ "integer",
            .data$type %in% "number" ~ "numeric",
            # .data$type %in% "array" ~ "character", # need to do some testing on array types
            startsWith(.data$type, "string") ~ "character"
          ),
        is_scalar =
          .data$type %in% c("boolean", "integer", "number") |
          startsWith(.data$type, "string")
      ) %>%
      # not sure how to deal with the other types, so ignoring
      dplyr::filter(!is.na(.data$class)),
    error = function(e) {
      "Error downloading most recent settings from {.url {url}}" %>%
        cli::cli_alert_danger()
      "Using setting listing downloaded {.val {as.character(attr(df_rstudio_prefs, 'date'))}}" %>%
        cli::cli_alert_success()
      cat("\n")

      df_rstudio_prefs
    }
  )
}
