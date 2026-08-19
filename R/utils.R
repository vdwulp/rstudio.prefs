#' Check Min RStudio Version
#'
#' Return error if minimum version requirement not met.
#'
#' @param version string of min required version number
#' @export
#' @return path string to RStudio `rstudio-prefs.json` file
#' @return Called for its side effect; aborts with an error if the version
#'   requirement is not met, otherwise returns invisibly.
#' @author Daniel D. Sjoberg
#'
#' @examples
#' if (interactive()) {
#'   check_min_rstudio_version("1.3")
#' }
check_min_rstudio_version <- function(version) {
  if (rstudioapi::getVersion() < version) {
    paste("RStudio version", version, "or greater required.") %>%
      rlang::abort()
  }
}

#' RStudio Config Path
#'
#' Copy of the internal function `usethis:::rstudio_config_path()`
#'
#' @param ... strings added to the RStudio config path
#'
#' @export
#' @return path string to RStudio `rstudio-prefs.json` file
#' @author Daniel D. Sjoberg
#'
#' @examples
#' if (interactive()) {
#'   rstudio_config_path()
#' }
rstudio_config_path <- function(...) {
  if (is_windows()) {
    base <- rappdirs::user_config_dir("RStudio", appauthor = NULL)
  }
  else {
    base <- rappdirs::user_config_dir("rstudio", os = "unix")
  }
  fs::path(base, ...)
}

#' Is OS Windows?
#'
#' Copy of the internal function `usethis:::is_windows()`
#'
#' @param ... not used
#'
#' @return logical
#' @keywords internal
#' @noRd
is_windows <- function(...) {
  .Platform$OS.type == "windows"
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


#' Create a back-up copy of a file
#'
#' Function copies the file, and adds today's date to the end of the file name.
#'
#' @param file path and file location.
#' @param quiet logical
#' @keywords internal
#' @noRd
backup_file <- function(file, quiet = FALSE) {
  # if file does not exist, print msg and skip backup
  if (!fs::file_exists(file)) {
    if (!quiet) {
      cli::cli_alert_info("File {.val {file}} does not exist. No backup created.")
    }
    return(invisible(NULL))
  }

  path_dir <- fs::path_dir(file)
  path_ext <- paste0(".", fs::path_ext(file))
  new_file_name <-
    fs::path_file(file) %>% {
      gsub(
        pattern = path_ext,
        replacement = paste0(" ", Sys.Date(), path_ext),
        x = .,
        fixed = TRUE
      )
    }

  if (fs::file_exists(fs::path(path_dir, new_file_name))) {
    if (!quiet) {
      paste(
        "Aborting backup;",
        "file {.val {fs::path(path_dir, new_file_name)}} already exists."
      ) %>%
        cli::cli_alert_danger()
    }
    return(invisible(NULL))
  }

  fs::file_copy(
    path = file,
    new_path = fs::path(path_dir, new_file_name),
    overwrite = FALSE
  )
  if (!quiet) {
    cli::cli_alert_success("File {.val {fs::path(path_dir, new_file_name)}} saved as backup.")
  }
}


#' Write JSON file
#'
#' Simple wrapper for `jsonlite::write_json()`, where path directory is created
#' if it does not already exist. The `jsonlite::write_json()` includes arguments
#' `pretty = TRUE` and `auto_unbox = TRUE`
#'
#' @inheritParams jsonlite::write_json
#'
#' @return NULL
#' @keywords internal
#' @noRd
write_json <- function(x, path, .backup) {
  # backup file if requested ---------------------------------------------------
  if (isTRUE(.backup)) backup_file(path)

  # if folder does not exist, create folder
  if(!fs::dir_exists(fs::path_dir(path))) {
    fs::dir_create(fs::path_dir(path))
  }

  # write JSON file
  jsonlite::write_json(
    x,
    path = path,
    pretty = TRUE,
    auto_unbox = TRUE
  )

  cli::cli_alert_success("File {.val {path}} updated.")
  cli::cli_ul("Restart RStudio for updates to take effect.")
}
