# check_min_rstudio_version() --------------------------------------------------

test_that("check_min_rstudio_version() - aborts when version is too low", {
  local_mocked_bindings(
    getVersion = function() "1.2",
    .package = "rstudioapi"
  )

  expect_error(check_min_rstudio_version("1.3"))
})

test_that("check_min_rstudio_version() - passes when version is met", {
  local_mocked_bindings(
    getVersion = function() "1.3",
    .package = "rstudioapi"
  )

  expect_no_error(check_min_rstudio_version("1.3"))
})


# rstudio_config_path() + is_windows() ----------------------------------------

test_that("rstudio_config_path() + is_windows() - runs without error", {
  expect_no_error(rstudio_config_path())
})

test_that("rstudio_config_path() - returns RStudio (uppercase) on windows", {
  local_mocked_bindings(is_windows = function(...) TRUE)

  expect_true(grepl("RStudio", rstudio_config_path()))
})

test_that("rstudio_config_path() - returns rstudio (lowercase) on non-windows", {
  local_mocked_bindings(is_windows = function(...) FALSE)

  expect_true(grepl("rstudio", rstudio_config_path()))
})

test_that("rstudio_config_path() - appends path components", {
  local_mocked_bindings(is_windows = function(...) FALSE)

  result <- rstudio_config_path("snippets", "r.snippets")
  expect_true(grepl("rstudio/snippets/r.snippets", result))
})


# write_json() + backup_file() -------------------------------------------------

test_that("write_json() - writes and backups JSON without error", {
  path <- file.path(tempdir(), "test_folder", "test_json.json")

  suppressMessages(
    expect_no_error(
      write_json(
        list(a = 1, b = 2),
        path = path,
        .backup = TRUE
      )
    )
  )

  # Also when backup is created
  suppressMessages(
    expect_no_error(
      write_json(
        list(a = 1, b = 2),
        path = path,
        .backup = TRUE
      )
    )
  )

  # Also when backup file already exists
  suppressMessages(
    expect_no_error(
      write_json(
        list(a = 1, b = 2),
        path = path,
        .backup = TRUE
      )
    )
  )
})
