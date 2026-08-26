# backup_file() ----------------------------------------------------------------


# write_json() -----------------------------------------------------------------

test_that("write_json() - writes JSON without error", {
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
