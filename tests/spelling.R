if (requireNamespace('spelling', quietly = TRUE) && !nzchar(Sys.getenv("R_COVR")))
  spelling::spell_check_test(vignettes = TRUE, error = FALSE,
                             skip_on_cran = TRUE)
