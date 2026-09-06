# use_rstudio_secondary_repo() -------------------------------------------------

test_that("use_rstudio_secondary_repo() - returns NULL when not interactive", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL)
  )

  local_mocked_bindings(
    interactive = function() FALSE,              # <-- not interactive
    .package = "base"
  )

  suppressMessages(
    result <- use_rstudio_secondary_repo(
      ropensci = "https://ropensci.r-universe.dev"
    )
  )

  expect_null(result)
})

test_that("use_rstudio_secondary_repo() - returns NULL when no updates needed", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) FALSE    # <-- no updates
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    .package = "base"
  )

  local_mocked_bindings(
    readRStudioPreference = function(name, default)
      list(name = "Global (CDN)", host = "RStudio",
           url = "https://cran.rstudio.com/", repos = "",
           country = "us",
           secondary = "ropensci|https://ropensci.r-universe.dev"),
    .package = "rstudioapi"
  )

  suppressMessages(
    result <- use_rstudio_secondary_repo(
      ropensci = "https://ropensci.r-universe.dev"
    )
  )

  expect_null(result)
})

test_that("use_rstudio_secondary_repo() - returns NULL when user declines", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE
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
    result <- use_rstudio_secondary_repo(
      ropensci = "https://ropensci.r-universe.dev"
    )
  )

  expect_null(result)
})

test_that("use_rstudio_secondary_repo() - aborts when arguments are unnamed", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    .package = "base"
  )

  expect_error(
    use_rstudio_secondary_repo("https://ropensci.r-universe.dev"),
    "named"
  )
})

test_that("use_rstudio_secondary_repo() - adds new repo when no cran_mirror exists", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) "y",
    .package = "base"
  )

  local_mocked_bindings(
    readRStudioPreference = function(name, default) NULL,  # <-- no existing prefs
    writeRStudioPreference = function(name, value) invisible(NULL),
    .package = "rstudioapi"
  )

  suppressMessages(
    result <- use_rstudio_secondary_repo(
      ropensci = "https://ropensci.r-universe.dev"
    )
  )

  expect_type(result, "list")
  expect_equal(result$secondary, "ropensci|https://ropensci.r-universe.dev")
})

test_that("use_rstudio_secondary_repo() - adds repo to existing secondary repos", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) "y",
    .package = "base"
  )

  local_mocked_bindings(
    readRStudioPreference = function(name, default)
      list(name = "Global (CDN)", host = "RStudio",
           url = "https://cran.rstudio.com/", repos = "",
           country = "us",
           secondary = "ropensci|https://ropensci.r-universe.dev"),
    writeRStudioPreference = function(name, value) invisible(NULL),
    .package = "rstudioapi"
  )

  suppressMessages(
    result <- use_rstudio_secondary_repo(
      username = "https://username.r-universe.dev"
    )
  )

  expect_equal(result$secondary, "ropensci|https://ropensci.r-universe.dev|username|https://username.r-universe.dev")
})

test_that("use_rstudio_secondary_repo() - renames repo with same URL", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) "y",
    .package = "base"
  )

  local_mocked_bindings(
    readRStudioPreference = function(name, default)
      list(name = "Global (CDN)", host = "RStudio",
           url = "https://cran.rstudio.com/", repos = "",
           country = "us",
           secondary = "oldname|https://ropensci.r-universe.dev"),
    writeRStudioPreference = function(name, value) invisible(NULL),
    .package = "rstudioapi"
  )

  suppressMessages(
    result <- use_rstudio_secondary_repo(
      ropensci = "https://ropensci.r-universe.dev"
    )
  )

  expect_equal(result$secondary, "ropensci|https://ropensci.r-universe.dev")
})

test_that("use_rstudio_secondary_repo() - replaces repo with same name", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) "y",
    .package = "base"
  )

  local_mocked_bindings(
    readRStudioPreference = function(name, default)
      list(name = "Global (CDN)", host = "RStudio",
           url = "https://cran.rstudio.com/", repos = "",
           country = "us",
           secondary = "unirepo|https://ropensci.r-universe.dev"),
    writeRStudioPreference = function(name, value) invisible(NULL),
    .package = "rstudioapi"
  )

  suppressMessages(
    result <- use_rstudio_secondary_repo(
      unirepo = "https://username.r-universe.dev"
    )
  )

  expect_equal(result$secondary, "unirepo|https://username.r-universe.dev")
})

test_that("use_rstudio_secondary_repo() - removes repo passed with value NULL", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL),
    pretty_print_updates = function(...) TRUE
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    readline = function(prompt) "y",
    .package = "base"
  )

  local_mocked_bindings(
    readRStudioPreference = function(name, default)
      list(name = "Global (CDN)", host = "RStudio",
           url = "https://cran.rstudio.com/", repos = "",
           country = "us",
           secondary = "ropensci|https://ropensci.r-universe.dev|username|https://username.r-universe.dev"),
    writeRStudioPreference = function(name, value) invisible(NULL),
    .package = "rstudioapi"
  )

  suppressMessages(
    result <- use_rstudio_secondary_repo(
      ropensci = NULL
    )
  )

  expect_equal(result$secondary, "username|https://username.r-universe.dev")
})

test_that("use_rstudio_secondary_repo() - returns NULL when removing non-existent repo", {
  local_mocked_bindings(
    check_min_rstudio_version = function(...) invisible(NULL)
  )

  local_mocked_bindings(
    interactive = function() TRUE,
    .package = "base"
  )

  local_mocked_bindings(
    readRStudioPreference = function(name, default)
      list(name = "Global (CDN)", host = "RStudio",
           url = "https://cran.rstudio.com/", repos = "",
           country = "us",
           secondary = "ropensci|https://ropensci.r-universe.dev"),
    .package = "rstudioapi"
  )

  capture.output(
    suppressMessages(
      result <- use_rstudio_secondary_repo(
        nonexistent = NULL
      )
    )
  )

  expect_null(result)
})


# repo_string_as_named_list() --------------------------------------------------

test_that("repo_string_as_named_list() - converts string to named list", {
  expect_equal(
    repo_string_as_named_list('ropensci|https://ropensci.r-universe.dev|username|https://username.r-universe.dev'),
    list(ropensci = "https://ropensci.r-universe.dev",
         username = "https://username.r-universe.dev")
  )
})

test_that("repo_string_as_named_list() - returns empty list for NULL input", {
  expect_equal(
    repo_string_as_named_list(NULL),
    list()
  )
})
