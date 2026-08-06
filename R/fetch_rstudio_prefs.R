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
