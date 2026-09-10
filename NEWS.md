# rstudio.prefs (development version)

### Enhancements

* `use_rstudio_prefs()` now supports array preferences via a list of strings
  ([#28](https://github.com/vdwulp/rstudio.prefs/issues/28)). For example:
  `use_rstudio_prefs(busy_exclusion_list = list("tmux", "screen"))`. Character
  vectors are also accepted for convenience.

  Current array preferences:
  - `always_shown_extensions`
  - `always_shown_files`
  - `browser_fixed_width_fonts`
  - `busy_exclusion_list`
  - `disabled_aria_live_announcements`
  - `file_monitor_ignored_components`
  - `spelling_custom_dictionaries`
  - `terminal_ignored_environment_variables`
  - `zotero_libraries`

* `use_rstudio_prefs()` now validates string preferences when a fixed set of
  allowed values is defined and warns on invalid values
  ([#13](https://github.com/vdwulp/rstudio.prefs/issues/13)).

### Fixes

* `use_rstudio_prefs()` now prevents errors from
  `rstudioapi::writeRStudioPreference()`, while continuing with other
  preferences. Preferences with invalid types are skipped, numeric values are
  converted to the correct type where applicable
  ([#31](https://github.com/vdwulp/rstudio.prefs/issues/31)).

* Replaced deprecated `purrr::update_list()` with base R `modifyList()` in
  `use_rstudio_secondary_repo()`. This replacement also fixed removal of the old
  repo name when its URL is reassigned to a new name, instead of leaving it as
  an empty entry.

* Fixed error when removing a non-existent secondary repo with
  `use_rstudio_secondary_repo(repo_name = NULL)`.

* Fixed documentation errors in `check_min_rstudio_version()`, and typos in
  `backup_file()` and `is_windows()`.

### Other

* Reorganized source files to bundle related functions and better reflect their
  contents.

* Aligned test files to source files, and expanded test coverage.

* Added package logo.


# rstudio.prefs 0.2.0

### New

* `use_rstudio_keyboard_shortcut()` now supports shortcut removal by passing
  `NULL` as the value ([#22](https://github.com/vdwulp/rstudio.prefs/issues/22)).

### Fixes

* Fixed bug in `use_rstudio_keyboard_shortcut()` where reassigning a shortcut to
  a function that already had one produced a corrupted `addins.json` entry with
  a `.1` suffix, causing the new shortcut to silently fail
  ([#22](https://github.com/vdwulp/rstudio.prefs/issues/22)).

* Replaced deprecated `purrr::update_list()` with base R `modifyList()` in
  `use_rstudio_keyboard_shortcut()`
  ([#22](https://github.com/vdwulp/rstudio.prefs/issues/22)).

* Fixed `check_shortcut_consistency()` erroring early when passed a non-existent
  name; wrapped `eval(rlang::parse_expr(.))` in `tryCatch()`
  ([#24](https://github.com/vdwulp/rstudio.prefs/pull/24)).

* Updated URL in `fetch_rstudio_prefs()` to current docs, fixing missing
  preferences such as `enable_splash_screen`
  ([#20](https://github.com/vdwulp/rstudio.prefs/issues/20)).

* Updated `@return` documentation for `use_rstudio_prefs()`,
  `use_rstudio_secondary_repo()`, and `use_rstudio_keyboard_shortcut()`
  ([#19](https://github.com/vdwulp/rstudio.prefs/pull/19)).

### Other

* Maintainer transferred from Daniel D. Sjoberg to S.A. van der Wulp
  ([#20](https://github.com/vdwulp/rstudio.prefs/issues/20)).

* Modernized package title, description, internal prefs data and GitHub Actions
  workflows. Increased testing coverage.


# rstudio.prefs 0.1.9

* Fix for `use_rstudio_secondary_repo()` when it is used to set the first secondary repository. (#14)

* Updated `use_rstudio_prefs()` and `use_rstudio_secondary_repo()` to use the {rstudioapi} package to read and write RStudio preferences instead of manually manipulating the preferences JSON file. (#12)

* Corrected the folder location of the app data folder from `RStudio` to `rstudio` on Unix. (#11)

# rstudio.prefs 0.1.8

* Updated URL where RStudio preferences are downloaded from in `fetch_rstudio_prefs()`.

* Updated pretty printing style.

* If no changes will be made, functions are now aborted before saving/backing-up the config files.

# rstudio.prefs 0.1.7

* Exporting utility function `repo_string_as_named_list()`.

* Fixing bug in `use_rstudio_secondary_repo()` where existing secondary repositories could not be deleted (i.e. set to `NULL`).

# rstudio.prefs 0.1.6

* Exporting utility functions `rstudio_config_path()` and `check_min_rstudio_version()`.

* Repositories may now be removed with `use_rstudio_secondary_repo(repo_name = NULL)`.

* Updated documentation for `use_rstudio_secondary_repo()` to indicate when the country will be set to US.

# rstudio.prefs 0.1.5

* Updates to documentation.

* Improved error messaging.

* Added additional unit tests.

* Removed type 'array' from `fetch_rstudio_prefs()`. This type needs further testing before it's rolled out. Users can still pass array updates, but they will see a note about proceeding with caution.

* Updates to the way the preferences are printed to the console before being written to file.

* Updates to the consistency checks in `use_rstudio_keyboard_shortcut()`.

# rstudio.prefs 0.1.4

* Added RStudio add-in function `make_path_norm()`.

* Documentation updates and tidying up for CRAN release.

# rstudio.prefs 0.1.3

* Function `fetch_rstudio_settings_table()` has been renamed to `fetch_rstudio_prefs()`. The function now returns tibble with lowercase column names and a `is_scalar` column has been added indicating whether the preference setting should be length one.

# rstudio.prefs 0.1.2

* Updated API for `use_rstudio_keyboard_shortcut()` to use the keyboard shortcut as the named argument and the function that will be executed as the argument value.

* Performing a check that the directory exists before attempting to write JSON file. If directory does not exist, it is created.

* Bug fix for file back-up. If file does not already exist, the back-up attempt is skipped.

# rstudio.prefs 0.1.1

* Bug fix when none of the new preferences are currently listed in the preferences JSON file.

# rstudio.prefs 0.1.0

* First release
