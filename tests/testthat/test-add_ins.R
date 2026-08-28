# make_path_norm() -------------------------------------------------------------

test_that("make_path_norm() - passes normalized path to modifyRange", {
  modified <- NULL

  local_mocked_bindings(
    getActiveDocumentContext = function() list(
      id = "test_id",
      selection = list(list(range = list(), text = "a/./b"))
    ),
    modifyRange = function(range, text, id) modified <<- text,
    .package = "rstudioapi"
  )

  make_path_norm()
  expect_equal(modified, "a/b")
})

test_that("make_path_norm() - flips backslashes to forward slashes", {
  modified <- NULL

  local_mocked_bindings(
    getActiveDocumentContext = function() list(
      id = "test_id",
      selection = list(list(range = list(), text = "a\\b"))
    ),
    modifyRange = function(range, text, id) modified <<- text,
    .package = "rstudioapi"
  )

  make_path_norm()
  expect_equal(modified, "a/b")
})

test_that("make_path_norm() - normalizes multiple selections", {
  modified <- list()

  local_mocked_bindings(
    getActiveDocumentContext = function() list(
      id = "test_id",
      selection = list(
        list(range = list(), text = "a/./b"),
        list(range = list(), text = "c\\d")
      )
    ),
    modifyRange = function(range, text, id) modified[[length(modified) + 1]] <<- text,
    .package = "rstudioapi"
  )

  make_path_norm()
  expect_setequal(modified, c("a/b", "c/d"))
})
