#' Set RStudio Secondary Repository
#'
#' This function updates the RStudio preferences saved in
#' the `rstudio-prefs.json` file to include the secondary repositories
#' passed by the user. If a new name for an existing repository is
#' passed by the user, the name will be updated in the JSON file.
#'
#' A note for users outside of the USA.
#' If the country in `.$cran_mirror$country` has not been previously recorded
#' in the JSON preferences file (typically, auto set by RStudio),
#' the `use_rstudio_secondary_repo()` function will set `"country" = "us"`.
#'
#' @param ... series of named secondary repositories, e.g.
#' `ropensci = "https://ropensci.r-universe.dev"`
#'
#' @export
#' @return updates RStudio `rstudio-prefs.json` file and returns a list of the
#'   updated secondary repositories or NULL if there are none.
#' @author Daniel D. Sjoberg
#'
#' @examplesIf interactive()
#' use_rstudio_secondary_repo(
#'   ropensci = "https://ropensci.r-universe.dev",
#'   ddsjoberg = "https://ddsjoberg.r-universe.dev"
#' )

use_rstudio_secondary_repo <- function(...) {
  # check whether fn may be used -----------------------------------------------
  check_min_rstudio_version("1.3")
  if (!interactive()) {
    "{.code use_rstudio_secondary_repo()} must be run interactively." %>%
      cli::cli_alert_danger()
    return(invisible())
  }

  # save lists of existing and updated repos -----------------------------------
  user_passed_updated_repos <- rlang::dots_list(...)
  if (!rlang::is_named(user_passed_updated_repos)) {
    rlang::abort("Each argument must be named.")
  }
  list_current_cran_mirror <-
    rstudioapi::readRStudioPreference("cran_mirror", default = NULL)

  # if no secondary repos exist, create the structure for them -----------------
  if (is.null(list_current_cran_mirror)) {
    # i took these values from my own settings...may need to be modified for broader use
    list_current_cran_mirror <-
      list("name" = "Global (CDN)",
           "host" = "RStudio",
           "url" = "https://cran.rstudio.com/",
           "repos" = "",
           "country" = "us",
           "secondary" = NULL)
  }

  # parse the secondary repo string --------------------------------------------
  current_repos <-
    repo_string_as_named_list(list_current_cran_mirror$secondary)

  user_passed_updated_repos <-
    union(
      # if one of the new repos has the same value but new name as a previous
      # then add a new NULL value to the updates list
      current_repos[unlist(current_repos) %in% unlist(user_passed_updated_repos)] %>% names(),
      # set any existing named repos with same name as passed list to NULL
      current_repos[names(current_repos) %in% names(user_passed_updated_repos)] %>% names()
    ) %>%
    purrr::compact() %>%
    {stats::setNames(rep_len(list(NULL), length.out = length(.)), .)} %>%
    # add user-defined repos to the list
    purrr::list_modify(!!!purrr::compact(user_passed_updated_repos))

  # print updates that will be made --------------------------------------------
  any_update <- pretty_print_updates(current_repos, user_passed_updated_repos)
  # if no updates, abort function execution
  if (!any_update) {
    return(invisible(NULL))
  }
  # ask user to abort or not
  if (!startsWith(tolower(readline("Would you like to continue? [y/n] ")), "y")) {
    return(invisible(NULL))
  }

  # create final list of repos -------------------------------------------------
  list_current_cran_mirror$secondary <-
    current_repos %>%
    purrr::update_list(!!!user_passed_updated_repos) %>%
    purrr::imap_chr(~paste0(.y, "|", .x)) %>%
    paste(collapse = "|")

  # update preferences ---------------------------------------------------------
  rstudioapi::writeRStudioPreference(
    name = "cran_mirror",
    value = list_current_cran_mirror
  )
  return(invisible(list_current_cran_mirror))
}


#' Convert secondary repo string to named list
#'
#' The secondary repo string uses `|` to separate the repo names and their
#' values, as well as two different repos, e.g.
#' `'ropensci|https://ropensci.r-universe.dev|ddsjoberg|https://ddsjoberg.r-universe.dev'`.
#'
#' @param x secondary repository string from
#' `"rstudio-prefs.json"` --> `"cran_mirror"` --> `"secondary"`
#' @export
#' @return named list
#' @author Daniel D. Sjoberg
#'
#' @examples
#' repo_string_as_named_list(
#'   'ropensci|https://ropensci.r-universe.dev|ddsjoberg|https://ddsjoberg.r-universe.dev'
#' )
repo_string_as_named_list <- function(x) {
  if (is.null(x)) return(list())
  # split string by |
  xx <- strsplit(x, "|", fixed = TRUE) %>% unlist()

  # use every other element as the value and the name and return as list
  xx[!as.logical(seq_len(length(xx)) %% 2)] %>%
    stats::setNames(xx[as.logical(seq_len(length(xx)) %% 2)]) %>%
    as.list()
}
