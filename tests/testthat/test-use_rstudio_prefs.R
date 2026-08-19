# use_rstudio_prefs() ----------------------------------------------------------

test_that("use_rstudio_prefs() - returns NULL when not interactive", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL)
  )

  local_mocked_bindings(
    interactive = function() FALSE,              # <-- not interactive
    .package = "base"
  )

  suppressMessages(
    result <- use_rstudio_prefs(
      rainbow_parentheses = TRUE
    )
  )

  expect_null(result)
})

test_that("use_rstudio_prefs() - returns NULL when no updates needed", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) FALSE,  # <-- no updates
    check_prefs_consistency = function(...) invisible(NULL)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    .package = "base"
  )

  local_mocked_bindings(
    readRStudioPreference = function(name, default) TRUE,
    .package = "rstudioapi"
  )

  suppressMessages(
    result <- use_rstudio_prefs(
      rainbow_parentheses = TRUE
    )
  )

  expect_null(result)
})

test_that("use_rstudio_prefs() - returns NULL when user declines", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE,
    check_prefs_consistency = function(...) invisible(NULL)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) "n",             # <-- user declines
    .package = "base"
  )

  local_mocked_bindings(
    readRStudioPreference = function(name, default) NULL,
    .package = "rstudioapi"
  )

  suppressMessages(
    result <- use_rstudio_prefs(
      rainbow_parentheses = TRUE
    )
  )

  expect_null(result)
})

test_that("use_rstudio_prefs() - returns updated list when user confirms", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE,
    check_prefs_consistency = function(...) invisible(NULL)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) "y",
    .package = "base"
  )

  local_mocked_bindings(
    readRStudioPreference = function(name, default) NULL,
    writeRStudioPreference = function(name, value) invisible(NULL),
    .package = "rstudioapi"
  )

  suppressMessages(
    result <- use_rstudio_prefs(
      rainbow_parentheses = TRUE
    )
  )

  expect_type(result, "list")
  expect_equal(result[["rainbow_parentheses"]], TRUE)
  expect_length(result, 1)
})

test_that("use_rstudio_prefs() - returns updated list with multiple prefs", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE,
    check_prefs_consistency = function(...) invisible(NULL)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) "y",
    .package = "base"
  )

  local_mocked_bindings(
    readRStudioPreference = function(name, default) NULL,
    writeRStudioPreference = function(name, value) invisible(NULL),
    .package = "rstudioapi"
  )

  suppressMessages(
    result <- use_rstudio_prefs(
      rainbow_parentheses = TRUE,
      always_save_history = FALSE
    )
  )

  expect_type(result, "list")
  expect_equal(result[["rainbow_parentheses"]], TRUE)
  expect_equal(result[["always_save_history"]], FALSE)
  expect_length(result, 2)
})

test_that("use_rstudio_prefs() - aborts when arguments are unnamed", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    .package = "base"
  )

  expect_error(
    use_rstudio_prefs(TRUE),
    "named"
  )
})


# check_prefs_consistency() ----------------------------------------------------

test_that("check_prefs_consistency() - aborts on duplicate preference names", {
  local_mocked_bindings(
    fetch_rstudio_prefs = function() df_rstudio_prefs
  )

  expect_error(
    check_prefs_consistency(
      list(not_a_pref = TRUE, not_a_pref = TRUE, not_a_pref = TRUE)
    ),
    "Duplicate"
  )
})

test_that("check_prefs_consistency() - warns but does not error on unknown pref names", {
  local_mocked_bindings(
    fetch_rstudio_prefs = function() df_rstudio_prefs
  )

  suppressMessages(
    expect_no_error(
      check_prefs_consistency(
        list(not_a_pref = TRUE, not_a_pref2 = TRUE, not_a_pref3 = TRUE)
      )
    )
  )
})

test_that("check_prefs_consistency() - warns but does not error on wrong type: logical expected", {
  local_mocked_bindings(
    fetch_rstudio_prefs = function() df_rstudio_prefs
  )

  suppressMessages(
    expect_no_error(
      check_prefs_consistency(
        list(rainbow_parentheses = "TRUE")
      )
    )
  )
})

test_that("check_prefs_consistency() - warns but does not error on wrong type: string expected", {
  local_mocked_bindings(
    fetch_rstudio_prefs = function() df_rstudio_prefs
  )

  suppressMessages(
    expect_no_error(
      check_prefs_consistency(
        list(ansi_console_mode = TRUE)
      )
    )
  )
})

test_that("check_prefs_consistency() - warns but does not error on wrong type: integer expected", {
  local_mocked_bindings(
    fetch_rstudio_prefs = function() df_rstudio_prefs
  )

  suppressMessages(
    expect_no_error(
      check_prefs_consistency(
        list(margin_column = "hello")
      )
    )
  )
})

test_that("check_prefs_consistency() - warns but does not error on length > 1 for scalar pref", {
  local_mocked_bindings(
    fetch_rstudio_prefs = function() df_rstudio_prefs
  )

  suppressMessages(
    expect_no_error(
      check_prefs_consistency(
        list(margin_column = c(1L, 80L))
      )
    )
  )
})

test_that("check_prefs_consistency() - warns but does not error on wrong type: numeric expected", {
  local_mocked_bindings(
    fetch_rstudio_prefs = function() df_rstudio_prefs
  )

  suppressMessages(
    expect_no_error(
      check_prefs_consistency(
        list(font_size_points = "hello")
      )
    )
  )
})

test_that("check_prefs_consistency() - no error or warning on valid input", {
  local_mocked_bindings(
    fetch_rstudio_prefs = function() df_rstudio_prefs
  )

  suppressMessages(
    expect_no_error(
      check_prefs_consistency(
        list(rainbow_parentheses = TRUE)
      )
    )
  )
})


# fetch_rstudio_prefs() --------------------------------------------------------

test_that("fetch_rstudio_prefs() - returns a tibble with expected columns", {
  skip_on_cran()
  skip_if_offline()

  capture.output(
    suppressMessages(
      result <- fetch_rstudio_prefs()
    )
  )

  expect_s3_class(result, "data.frame")
  expect_true(all(c("property", "type", "class", "is_scalar") %in% names(result)))
})

test_that("fetch_rstudio_prefs() - returns only supported types", {
  skip_on_cran()
  skip_if_offline()

  capture.output(
    suppressMessages(
      result <- fetch_rstudio_prefs()
    )
  )

  expect_false(any(is.na(result$class)))
  expect_true(all(result$class %in% c("logical", "integer", "numeric", "character")))
})

test_that("fetch_rstudio_prefs() - falls back to built-in data on download error", {
  local_mocked_bindings(
    read_html = function(...) stop("no internet"),
    .package = "rvest"
  )

  capture.output(
    suppressMessages(
      result <- fetch_rstudio_prefs()
    )
  )

  expect_s3_class(result, "data.frame")
  expect_true(all(c("property", "type", "class", "is_scalar") %in% names(result)))
})

test_that("fetch_rstudio_prefs() - known preference 'rainbow_parentheses' is present", {
  skip_on_cran()
  skip_if_offline()

  capture.output(
    suppressMessages(
      result <- fetch_rstudio_prefs()
    )
  )

  expect_true("rainbow_parentheses" %in% result$property)
  expect_equal(
    result$class[result$property == "rainbow_parentheses"],
    "logical"
  )
})
