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
