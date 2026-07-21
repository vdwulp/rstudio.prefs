#' Set RStudio Preferences
#'
#' This function updates the RStudio preferences saved in
#' the `rstudio-prefs.json` file. A full listing of preferences that may be
#' modified are listed here
#' \url{https://docs.rstudio.com/ide/server-pro/session-user-settings.html}
#'
#' @param ... series of RStudio preferences to update, e.g.
#' `always_save_history = FALSE, rainbow_parentheses = TRUE`
#'
#' @export
#' @return updates RStudio `rstudio-prefs.json` file and returns a list of the
#'   updated preferences or NULL if there are none. When `.write_json = FALSE`,
#'   returns the full list of all preferences without writing to file.
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


