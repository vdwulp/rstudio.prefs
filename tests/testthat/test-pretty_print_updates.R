# pretty_print_updates() -- prefs perspective ----------------------------------

# From `use_rstudio_prefs()` call site old and new arguments both contain the
# same keys, even if the value is NULL.

test_that("pretty_print_updates() - old and new are identical prints No Changes returns FALSE", {
  expect_output(
    result <- pretty_print_updates(
      list(rainbow_parentheses = TRUE),
      list(rainbow_parentheses = TRUE)
    ),
    "No Changes.*rainbow_parentheses.*TRUE.*TRUE"
  )
  expect_false(result)
})

test_that("pretty_print_updates() - value change prints Updates and returns TRUE", {
  expect_output(
    result <- pretty_print_updates(
      list(rainbow_parentheses = FALSE),
      list(rainbow_parentheses = TRUE)
    ),
    "Updates.*rainbow_parentheses.*FALSE.*TRUE"
  )
  expect_true(result)
})

test_that("pretty_print_updates() - old and new both NULL prints No Changes and returns FALSE", {
  expect_output(
    result <- pretty_print_updates(
      list(rainbow_parentheses = NULL),
      list(rainbow_parentheses = NULL)
    ),
    "No Changes.*rainbow_parentheses.*\\*.*\\*"
  )
  expect_false(result)
})

test_that("pretty_print_updates() - value change from NULL prints Updates and returns TRUE", {
  expect_output(
    result <- pretty_print_updates(
      list(rainbow_parentheses = NULL),
      list(rainbow_parentheses = TRUE)
    ),
    "Updates.*rainbow_parentheses.*\\*.*TRUE"
  )
  expect_true(result)
})

test_that("pretty_print_updates() - mixed: identical + change prints both sections and returns TRUE", {
  expect_output(
    result <- pretty_print_updates(
      list(rainbow_parentheses = TRUE, margin_column = 80L),
      list(rainbow_parentheses = TRUE, margin_column = 120L)
    ),
    "No Changes.*rainbow_parentheses.*TRUE.*TRUE.*Updates.*margin_column.*80.*120"
  )
  expect_true(result)
})

test_that("pretty_print_updates() - mixed: both NULL + change from NULL prints both sections and returns TRUE", {
  expect_output(
    result <- pretty_print_updates(
      list(rainbow_parentheses = NULL, margin_column = NULL),
      list(rainbow_parentheses = NULL, margin_column = 120L)
    ),
    "No Changes.*rainbow_parentheses.*\\*.*\\*.*Updates.*margin_column.*\\*.*120"
  )
  expect_true(result)
})


# pretty_print_updates() -- shortcuts perspective ------------------------------

# From `use_rstudio_keyboard_shortcut()` call site old argument just contains
# current shortcuts (content or empty, never value NULL), while new argument
# contains shortcuts update is requested for (may be removel with value NULL).

test_that("pretty_print_updates() - new assignment: key was free, returns TRUE", {
  expect_output(
    result <- pretty_print_updates(
      list(),
      list("Ctrl+Shift+/" = "make_path_norm")
    ),
    "Updates.*Ctrl\\+Shift\\+/.*\\*.*make_path_norm"
  )
  expect_true(result)
})

test_that("pretty_print_updates() - reassignment: key was taken, returns TRUE", {
  expect_output(
    result <- pretty_print_updates(
      list("Ctrl+Shift+/" = "print"),
      list("Ctrl+Shift+/" = "make_path_norm")
    ),
    "Updates.*Ctrl\\+Shift\\+/.*print.*make_path_norm"
  )
  expect_true(result)
})

test_that("pretty_print_updates() - vacate: key freed up, returns TRUE", {
  expect_output(
    result <- pretty_print_updates(
      list("Ctrl+Shift+/" = "make_path_norm"),
      list("Ctrl+Shift+/" = NULL)
    ),
    "Updates.*Ctrl\\+Shift\\+/.*make_path_norm.*\\*"
  )
  expect_true(result)
})

test_that("pretty_print_updates() - no change: key already set to same function, returns FALSE", {
  expect_output(
    result <- pretty_print_updates(
      list("Ctrl+Shift+/" = "make_path_norm"),
      list("Ctrl+Shift+/" = "make_path_norm")
    ),
    "No Changes.*Ctrl\\+Shift\\+/.*make_path_norm.*make_path_norm"
  )
  expect_false(result)
})

test_that("pretty_print_updates() - no change: key freed that was already free, returns FALSE", {
  expect_output(
    result <- pretty_print_updates(
      list(),
      list("Ctrl+Shift+/" = NULL)
    ),
    "No Changes.*Ctrl\\+Shift\\+/.*\\*.*\\*"
  )
  expect_false(result)
})

test_that("pretty_print_updates() - mixed: reassign to new key + vacate old key, returns TRUE", {
  expect_output(
    result <- pretty_print_updates(
      list("Ctrl+Shift+K" = "print", "Ctrl+Shift+/" = "make_path_norm"),
      list("Ctrl+Shift+K" = "make_path_norm", "Ctrl+Shift+/" = NULL)
    ),
    "Updates.*Ctrl\\+Shift\\+K.*print.*make_path_norm.*Ctrl\\+Shift\\+/.*make_path_norm.*\\*"
  )
  expect_true(result)
})

test_that("pretty_print_updates() - mixed: key set to same function + new assignment, returns TRUE", {
  expect_output(
    result <- pretty_print_updates(
      list("Ctrl+Shift+/" = "make_path_norm"),
      list("Ctrl+Shift+/" = "make_path_norm", "Ctrl+Shift+K" = "print")
    ),
    "No Changes.*Ctrl\\+Shift\\+/.*make_path_norm.*make_path_norm.*Updates.*Ctrl\\+Shift\\+K.*\\*.*print"
  )
  expect_true(result)
})
