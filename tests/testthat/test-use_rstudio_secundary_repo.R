# use_rstudio_secondary_repo() -------------------------------------------------


# repo_string_as_named_list() --------------------------------------------------

test_that("repo_string_as_named_list() - converts string to named list", {
  expect_equal(
    repo_string_as_named_list('ropensci|https://ropensci.r-universe.dev|ddsjoberg|https://ddsjoberg.r-universe.dev'),
    list(ropensci = "https://ropensci.r-universe.dev",
         ddsjoberg = "https://ddsjoberg.r-universe.dev")
  )
})

test_that("repo_string_as_named_list() - returns empty list for NULL input", {
  expect_equal(
    repo_string_as_named_list(NULL),
    list()
  )
})
