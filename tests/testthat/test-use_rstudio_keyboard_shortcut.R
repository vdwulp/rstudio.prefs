# use_rstudio_keyboard_shortcut() ----------------------------------------------

test_that("use_rstudio_keyboard_shortcut() - returns NULL when not interactive", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL)
  )

  local_mocked_bindings(
    interactive = function() FALSE,              # <-- not interactive
    .package = "base"
  )

  suppressMessages(
    result <- use_rstudio_keyboard_shortcut(
      "Ctrl+Shift+/" = "make_path_norm"
    )
  )

  expect_null(result)
})

test_that("use_rstudio_keyboard_shortcut() - returns NULL when no updates needed", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) FALSE,  # <-- no updates
    rstudio_config_path = function(x) file.path(withr::local_tempdir(), x)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    .package = "base"
  )

  result <- use_rstudio_keyboard_shortcut(
    "Ctrl+Shift+/" = "make_path_norm"
  )

  expect_null(result)
})

test_that("use_rstudio_keyboard_shortcut() - returns NULL when user declines", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE,
    rstudio_config_path = function(x) file.path(withr::local_tempdir(), x)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) "n",             # <-- user declines
    .package = "base"
  )

  result <- use_rstudio_keyboard_shortcut(
    "Ctrl+Shift+/" = "make_path_norm"
  )

  expect_null(result)
})

test_that("use_rstudio_keyboard_shortcut() - returns updated list when .write_json = FALSE", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE,
    rstudio_config_path = function(x) file.path(withr::local_tempdir(), x)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) "y",
    .package = "base"
  )

  suppressMessages(
    result <- use_rstudio_keyboard_shortcut(
      "Ctrl+Shift+/" = "make_path_norm",
      .write_json = FALSE
    )
  )

  expect_type(result, "list")
  expect_equal(result[["make_path_norm"]], "Ctrl+Shift+/")
  expect_length(result, 1)
})

test_that("use_rstudio_keyboard_shortcut() - writes JSON when .write_json = TRUE", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE,
    rstudio_config_path = function(x) file.path(tmp, x)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) "y",
    .package = "base"
  )

  suppressMessages(
    result <- use_rstudio_keyboard_shortcut(
      "Ctrl+Shift+/" = "make_path_norm",
      .write_json = TRUE
    )
  )

  expect_null(result)
  expect_true(fs::file_exists(file.path(tmp, "keybindings/addins.json")))
  written <- jsonlite::fromJSON(file.path(tmp, "keybindings/addins.json"))
  expect_equal(written[["make_path_norm"]], "Ctrl+Shift+/")
  expect_length(written, 1)
})

test_that("use_rstudio_keyboard_shortcut() - removes shortcut when NULL value passed", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE,
    rstudio_config_path = function(x) file.path(tmp, x)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) "y",
    .package = "base"
  )

  # Establish an existing shortcut
  fs::dir_create(file.path(tmp, "keybindings"))
  jsonlite::write_json(
    list("make_path_norm" = "Ctrl+Shift+/"),
    file.path(tmp, "keybindings/addins.json"),
    auto_unbox = TRUE
  )

  # Remove the shortcut
  suppressMessages(
    result <- use_rstudio_keyboard_shortcut(
      "Ctrl+Shift+/" = NULL
    )
  )

  expect_null(result)
  written <- jsonlite::fromJSON(file.path(tmp, "keybindings/addins.json"))
  expect_false("make_path_norm" %in% names(written))
  expect_length(written, 0)
})

test_that("use_rstudio_keyboard_shortcut() - reassigning function removes old key binding", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE,
    rstudio_config_path = function(x) file.path(tmp, x)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) "y",
    .package = "base"
  )

  # Establish an existing shortcut
  fs::dir_create(file.path(tmp, "keybindings"))
  jsonlite::write_json(
    list("make_path_norm" = "Ctrl+Shift+/"),
    file.path(tmp, "keybindings/addins.json"),
    auto_unbox = TRUE
  )

  # Reassign same function to a new key
  result <- suppressMessages(
    use_rstudio_keyboard_shortcut(
      "Ctrl+Shift+K" = "make_path_norm"
    )
  )

  expect_null(result)
  written <- jsonlite::fromJSON(file.path(tmp, "keybindings/addins.json"))
  expect_equal(written[["make_path_norm"]], "Ctrl+Shift+K")
  expect_false("Ctrl+Shift+/" %in% unlist(written))
  expect_length(written, 1)
})

test_that("use_rstudio_keyboard_shortcut() - reassigning key removes old function binding", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE,
    rstudio_config_path = function(x) file.path(tmp, x)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) "y",
    .package = "base"
  )

  # Establish an existing shortcut
  fs::dir_create(file.path(tmp, "keybindings"))
  jsonlite::write_json(
    list("make_path_norm" = "Ctrl+Shift+/"),
    file.path(tmp, "keybindings/addins.json"),
    auto_unbox = TRUE
  )

  # Reassign same key to a new function
  result <- suppressMessages(
    use_rstudio_keyboard_shortcut(
      "Ctrl+Shift+/" = "print"
    )
  )

  expect_null(result)
  written <- jsonlite::fromJSON(file.path(tmp, "keybindings/addins.json"))
  expect_equal(written[["print"]], "Ctrl+Shift+/")
  expect_false("make_path_norm" %in% names(written))
  expect_length(written, 1)
})

test_that("use_rstudio_keyboard_shortcut() - re-adding same shortcut does not change binding", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    # no mock of pretty_print_updates in this test
    rstudio_config_path = function(x) file.path(tmp, x)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) stop("readline should not be called"),  # <-- errors if prompted
    .package = "base"
  )

  # Establish an existing shortcut
  fs::dir_create(file.path(tmp, "keybindings"))
  jsonlite::write_json(
    list("make_path_norm" = "Ctrl+Shift+/"),
    file.path(tmp, "keybindings/addins.json"),
    auto_unbox = TRUE
  )

  # Re-add same binding - should run without prompting user
  capture.output(
    suppressMessages(
      result <- use_rstudio_keyboard_shortcut(
        "Ctrl+Shift+/" = "make_path_norm"
      )
    )
  )

  expect_null(result)
  written <- jsonlite::fromJSON(file.path(tmp, "keybindings/addins.json"))
  expect_equal(written[["make_path_norm"]], "Ctrl+Shift+/")
  expect_length(written, 1)
})

test_that("use_rstudio_keyboard_shortcut() - adding multiple shortcuts in one call", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE,
    rstudio_config_path = function(x) file.path(tmp, x)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) "y",
    .package = "base"
  )

  # Add multiple shortcuts in one call
  suppressMessages(
    result <- use_rstudio_keyboard_shortcut(
      "Ctrl+Shift+/" = "make_path_norm",
      "Ctrl+/" = "print",
      .write_json = FALSE
    )
  )

  expect_equal(result[["make_path_norm"]], "Ctrl+Shift+/")
  expect_equal(result[["print"]], "Ctrl+/")
  expect_length(result, 2)
})

test_that("use_rstudio_keyboard_shortcut() - removing multiple shortcuts in one call", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE,
    rstudio_config_path = function(x) file.path(tmp, x)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) "y",
    .package = "base"
  )

  # Establish existing shortcuts
  fs::dir_create(file.path(tmp, "keybindings"))
  jsonlite::write_json(
    list("make_path_norm" = "Ctrl+Shift+/", "print" = "Ctrl+/"),
    file.path(tmp, "keybindings/addins.json"),
    auto_unbox = TRUE
  )

  # Remove multiple shortcuts in one call
  suppressMessages(
    result <- use_rstudio_keyboard_shortcut(
      "Ctrl+Shift+/" = NULL,
      "Ctrl+/" = NULL,
      .write_json = FALSE
    )
  )

  expect_length(result, 0)
})

test_that("use_rstudio_keyboard_shortcut() - adding and removing shortcuts in one call", {
  tmp <- withr::local_tempdir()

  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE,
    rstudio_config_path = function(x) file.path(tmp, x)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) "y",
    .package = "base"
  )

  # Establish an existing shortcut
  fs::dir_create(file.path(tmp, "keybindings"))
  jsonlite::write_json(
    list("print" = "Ctrl+/"),
    file.path(tmp, "keybindings/addins.json"),
    auto_unbox = TRUE
  )

  # Add one shortcut and remove another in one call
  suppressMessages(
    result <- use_rstudio_keyboard_shortcut(
      "Ctrl+Shift+/" = "make_path_norm",
      "Ctrl+/" = NULL
    )
  )

  expect_null(result)
  written <- jsonlite::fromJSON(file.path(tmp, "keybindings/addins.json"))
  expect_equal(written[["make_path_norm"]], "Ctrl+Shift+/")
  expect_false("print" %in% names(written))
  expect_length(written, 1)
})


# check_shortcut_consistency() -------------------------------------------------

test_that("check_shortcut_consistency() - unnamed list", {
  expect_error(
    as.list(letters) %>% check_shortcut_consistency(),
    "must be named"
  )
})

test_that("check_shortcut_consistency() - non-string, non-NULL value", {
  expect_error(
    list(test = 5) %>% check_shortcut_consistency(),
    "must be a string"
  )
})

test_that("check_shortcut_consistency() - valid named function string", {
  expect_no_error(
    list(test = "make_path_norm") %>% check_shortcut_consistency()
  )
})

test_that("check_shortcut_consistency() - non-function string", {
  expect_error(
    list(test = "not_a_fun") %>% check_shortcut_consistency(),
    "string of a function name"
  )
})

test_that("check_shortcut_consistency() - non-function string that is a variable", {
  expect_error(
    list(test = "pi") %>% check_shortcut_consistency(),
    "string of a function name"
  )
})

test_that("check_shortcut_consistency() - NULL is allowed, explicit removal", {
  expect_no_error(
    list(test = NULL) %>% check_shortcut_consistency()
  )
})

test_that("check_shortcut_consistency() - mixed valid, NULL alongside valid shortcut", {
  expect_no_error(
    list(a = "make_path_norm", b = NULL) %>% check_shortcut_consistency()
  )
})
